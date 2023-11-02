# Create EFS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key

}

# module "efs" {
#   # source = "git::https://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@github.com/bankservafrica/bsa-modules-aws-migration.git//?ref=efs-module-V1.0"
#   source = "git::https://github.com/victordgr8t/bsa-modules-aws-migration-main.git//efs-module"
#   # source = "git::https://github.com/victordgr8t/efs-test-module.git//efs-module"


#   efs_name                        = var.efs_name
#   vpc_id                          = var.vpc_id
#   provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
#   throughput_mode                 = var.throughput_mode
#   encrypted                       = var.encrypted
#   kms_key_id                      = var.kms_key_id
#   tags                            = var.tags
#   whitelist_cidr                  = var.whitelist_cidr
#   whitelist_sg                    = var.whitelist_sg
#   efs_backup_policy_enabled       = var.efs_backup_policy_enabled
#   permissions                     = var.permissions
#   ap_directory                    = var.ap_directory
#   subnet_ids                      = var.subnet_ids
#   owner_gid                       = var.owner_gid
#   owner_uid                       = var.owner_uid

# }

resource "aws_efs_file_system" "ElasticFS_Storage" {
  creation_token = var.efs_name

  performance_mode                = var.performance_mode_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode

  encrypted  = var.encrypted
  kms_key_id = var.encrypted ? var.kms_key_id : null

  tags = merge(
    var.tags,
    {
      Name = "${var.efs_name}"
    }
  )
}

resource "aws_efs_access_point" "ElasticFS_Storage_access_point" {
  file_system_id = aws_efs_file_system.ElasticFS_Storage.id

  posix_user {
    gid = var.gid
    uid = var.uid
  }

  root_directory {
    path = var.ap_directory

    creation_info {
      owner_gid   = var.owner_gid
      owner_uid   = var.owner_gid
      permissions = var.permissions


    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.efs_name}-AccessPoint"
    }
  )
}
# Create Backup for EFS
resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.ElasticFS_Storage.id

  backup_policy {
    status = var.efs_backup_policy_enabled ? "ENABLED" : "DISABLED"
  }
}

resource "aws_instance" "efs_instance" {

  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = var.subnet_ids[0]
  security_groups = [aws_security_group.efs_sg.id]

  associate_public_ip_address = true

  tags = merge(
    var.tags,
    {
      Name = "${var.efs_name}-instance"
    }
  )

  user_data = <<-EOF
              #!/bin/bash
              sudo yum install -y amazon-efs-utils
              sudo mkdir /mnt/efs
              sudo mount -t efs ${aws_efs_file_system.ElasticFS_Storage.id}:/ /mnt/efs
              EOF
}

