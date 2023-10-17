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
#   source = "git::https://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@github.com/bankservafrica/bsa-modules-aws-migration.git//efs-module"

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
#   root_permissions                = var.root_permissions
#   ap_directory                    = var.ap_directory
#   subnet_ids                      = var.subnet_ids
#   owner_gid                       = var.owner_gid
#   owner_uid                       = var.owner_uid

# }

resource "aws_efs_file_system" "ElasticFS_storage" {
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

resource "aws_efs_access_point" "ElasticFS_storage_access_point" {
  count = var.ap_directory != "" ? 1 : 0

  file_system_id = aws_efs_file_system.ElasticFS_storage.id
  root_directory {
    path = var.ap_directory
    creation_info {
      owner_gid   = var.owner_gid
      owner_uid   = var.owner_uid
      permissions = var.root_permissions
    }
  }
}

#Create Backup for EFS
resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.ElasticFS_storage.id

  backup_policy {
    status = var.efs_backup_policy_enabled ? "ENABLED" : "DISABLED"
  }
}


