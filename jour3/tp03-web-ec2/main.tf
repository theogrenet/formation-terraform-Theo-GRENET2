# maint.tf 

# ----- NOUVEAU TP03 -----

# -----------------------------------------------------------------------------
# AMI Amazon Linux 2023 (derniere version officielle)
# -----------------------------------------------------------------------------

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# -----------------------------------------------------------------------------
# Key Pair : votre cle publique SSH locale
# AWS la deposera automatiquement dans ~/.ssh/authorized_keys de chaque EC2.
# -----------------------------------------------------------------------------
resource "aws_key_pair" "formation" {
  key_name   = "${local.name_prefix}-theo-key"
  public_key = file(pathexpand(var.public_key_path))

  tags = {
    Name  = "${local.name_prefix}-theo-key"
    Owner = "etudiant08"
  }
}

# -----------------------------------------------------------------------------
# Security Group : instances web
# Accepte SSH et HTTP UNIQUEMENT depuis le SG bastion (pas depuis un CIDR).
# Egress all pour que yum/dnf puisse installer nginx via NAT.
# -----------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-theo-web-sg"
  description = "SSH/HTTP depuis SG bastion uniquement"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-theo-web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_ssh" {
  security_group_id            = aws_security_group.web.id
  description                  = "SSH depuis le bastion"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion.id
}

resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id            = aws_security_group.web.id
  description                  = "HTTP depuis le bastion"
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion.id
}

resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  description       = "Egress all (yum/nginx updates)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# -----------------------------------------------------------------------------
# EC2 bastion (subnet public AZ-a)
# Seul point d'entree SSH vers les instances privees.
# -----------------------------------------------------------------------------
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[var.azs[0]].id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = aws_key_pair.formation.key_name
  associate_public_ip_address = true # ≠ map_public_ip_on_launch qui est sur aws_subnet

  tags = {
    Name = "${local.name_prefix}-theo-bastion"
    Role = "bastion"
  }
}

# -----------------------------------------------------------------------------
# EIP bastion : IP publique stable (survit aux reboots)
# -----------------------------------------------------------------------------

# EIP bastion : IP fixe qui survit aux reboots
# Attachée = gratuite / Non attachée = ~3.6 EUR/mois -> toujours détruire avec l'instance
resource "aws_eip" "bastion" {
  instance   = aws_instance.bastion.id
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = { Name = "${local.name_prefix}-theo-bastion-eip" }
}

# -----------------------------------------------------------------------------
# EC2 web (subnets prives, 1 par AZ via for_each sur map AZ->subnet_id)
# user_data rend une page nginx qui identifie l'AZ de l'instance.
# -----------------------------------------------------------------------------
resource "aws_instance" "web" {
  for_each = local.web_subnets

  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = each.value
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.formation.key_name

  # ${az} sera remplacé par "eu-west-3a" ou "eu-west-3b" selon l'instance
  user_data = templatefile("${path.module}/templates/nginx.sh.tftpl", {
    az = each.key
  })

  # Si je modifie le script -> recrée l'instance (user_data tourne qu'au 1er boot)
  user_data_replace_on_change = true

  lifecycle {
    create_before_destroy = true # nouvelle avant destruction ancienne = zéro downtime
  }

  tags = {
    Name = "${local.name_prefix}-theo-web-${each.key}"
    Role = "web"
    AZ   = each.key
  }
}


