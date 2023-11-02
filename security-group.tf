
# This resource block creates a security group for the EFS.
# The security group is named based on the `efs_name` variable and is associated with the specified VPC.
# Ingress and egress rules are dynamically generated based on the `whitelist_cidr` and `whitelist_sg` variables.
# The security group controls the inbound and outbound traffic to and from the EFS.
# resource "aws_security_group" "efs_sg" {
#   name        = "${var.efs_name}-sg"
#   description = "Security group for EFS"
#   vpc_id      = var.vpc_id


#   # Ingress rules for the security group based on CIDR blocks.
#   # The rules allow TCP traffic on the specified port from the whitelisted CIDR blocks.
#   dynamic "ingress" {
#     for_each = length(var.whitelist_cidr) == 0 ? [] : var.whitelist_cidr
#     content {
#       cidr_blocks = var.whitelist_cidr
#       from_port   = local.port
#       to_port     = local.port
#       protocol    = "tcp"
#     }
#   }

#   # Egress rules for the security group based on CIDR blocks.
#   # The rules allow all outbound traffic to the whitelisted CIDR blocks.
#   dynamic "egress" {
#     for_each = length(var.whitelist_cidr) == 0 ? [] : var.whitelist_cidr
#     content {
#       cidr_blocks = var.whitelist_cidr
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#     }
#   }


#   # Ingress rules for the security group based on security group IDs.
#   # The rules allow TCP traffic on the specified port from the whitelisted security groups.
#   dynamic "ingress" {
#     for_each = length(var.whitelist_sg) == 0 ? [] : var.whitelist_sg
#     content {
#       security_groups = var.whitelist_sg
#       from_port       = local.port
#       to_port         = local.port
#       protocol        = "tcp"
#     }
#   }

#   # Egress rules for the security group based on security group IDs.
#   # The rules allow all outbound traffic to the whitelisted security groups.
#   dynamic "egress" {
#     for_each = length(var.whitelist_sg) == 0 ? [] : var.whitelist_sg
#     content {
#       security_groups = var.whitelist_sg
#       from_port       = 0
#       to_port         = 0
#       protocol        = "-1"
#     }
#   }


#   # Tags assigned to the security group. Merges the provided `tags` variable with a default `Name` tag.
#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.efs_name}-sg"
#     }
#   )
# }


resource "aws_security_group" "efs_sg" {
  name        = "${var.efs_name}-sg"
  description = "Security group for EFS"
  vpc_id      = var.vpc_id

  # Ingress rules for the security group based on CIDR blocks.
  # The rules allow TCP traffic on the specified port from the whitelisted CIDR blocks.
  ingress {
    cidr_blocks = var.whitelist_cidr
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.whitelist_cidr
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  # Egress rules for the security group based on CIDR blocks.
  # The rules allow all outbound traffic to the whitelisted CIDR blocks.
  egress {
    cidr_blocks = var.whitelist_cidr
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  # Tags assigned to the security group. Merges the provided `tags` variable with a default `Name` tag.
  tags = merge(
    var.tags,
    {
      Name = "${var.efs_name}-sg"
    }
  )
}
