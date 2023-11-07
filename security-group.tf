# Create SG for EFS
resource "aws_security_group" "nfs_sg" {
  name   = "${var.efs_name}-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.whitelist_cidr) == 0 ? [] : var.whitelist_cidr
    content {
      cidr_blocks = var.whitelist_cidr
      from_port   = local.port
      to_port     = local.port
      protocol    = "tcp"
    }
  }
  dynamic "egress" {
    for_each = length(var.whitelist_cidr) == 0 ? [] : var.whitelist_cidr
    content {
      cidr_blocks = var.whitelist_cidr
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
    }
  }

  dynamic "ingress" {
    for_each = length(var.whitelist_sg) == 0 ? [] : var.whitelist_sg
    content {
      security_groups = var.whitelist_sg
      from_port       = local.port
      to_port         = local.port
      protocol        = "tcp"
    }
  }
  dynamic "egress" {
    for_each = length(var.whitelist_sg) == 0 ? [] : var.whitelist_sg
    content {
      security_groups = var.whitelist_sg
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
    }
  }

  dynamic "ingress" {
    for_each = length(var.whitelist_cidr) == 0 ? [] : var.whitelist_cidr
    content {
      cidr_blocks = var.whitelist_cidr
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
    }

  }

  tags = merge(
    var.tags,
    {
      Name = "${var.efs_name}-sg"
    }
  )
}
