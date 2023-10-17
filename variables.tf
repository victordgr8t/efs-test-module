
variable "efs_name" {
  description = "Name for EFS, SG"
  type        = string
  default     = "ElasticFS_storage"
}

variable "vpc_id" {
  description = "VPC ID for SG"
  type        = string
  default     = "vpc-031729aa862405f6b"
}

variable "performance_mode_mode" {
  description = "The file system performance mode"
  type        = string
  default     = "generalPurpose"
}

variable "provisioned_throughput_in_mibps" {
  description = "The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable with throughput_mode set to provisioned"
  type        = string
  default     = null
}

variable "throughput_mode" {
  description = "Throughput mode for the file system"
  type        = string
  default     = "bursting"
}

variable "encrypted" {
  description = "If true, the disk will be encrypted"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying kms_key_id, encrypted needs to be set to true"
  type        = string
  default     = null
}

variable "whitelist_cidr" {
  description = "List of CIDR blocks for whitelist"
  type        = list(string)
  default     = []
}

variable "whitelist_sg" {
  description = "List of Security Groups Block for whitelist"
  type        = list(string)
  default     = []
}

variable "efs_backup_policy_enabled" {
  type        = bool
  description = "If `true`, it will turn on automatic backups."
  default     = false
}

variable "root_permissions" {
  type    = string
  default = "0777"
}
variable "owner_gid" {
  description = "Specifies the POSIX group ID to apply to the root_directory"
  type        = number
  default     = 0
}
variable "owner_uid" {
  description = "Specifies the POSIX user ID to apply to the root_directory"
  type        = number
  default     = 0
}

variable "ap_directory" {
  description = "Create and directory to share using EFS access point"
  type        = string
  default     = "/testshare"
}

variable "subnet_ids" {
  description = "Subnets for the mount target"
  type        = list(string)
  default     = ["subnet-0f56f19f7a8b9b4a1"]
}

variable "tags" {
  type = map(any)
  default = {
    Env = "Dev"
  }
  description = "Resource tags"
}

variable "access_key" {
  type        = string
  description = "Access key of AWS"
  default     = "AKIAZK6OTII5IEYRYJ2R"

}

variable "secret_key" {
  type        = string
  description = "Secret Access key of AWS"
  default     = "/vWx++c5JyKwmb8Ex1orXCDm0hzXeRBnt4pgGY6g"

}

# variable "access_key" {
#   description = "AWS Access Key"
#   type        = string
#   default     = "ASIAZK6OTII5BURFLXFC"
# }

# variable "secret_key" {
#   description = "AWS Secret Key"
#   type        = string
#   default     = "/l91kk5t8wf8UksKQ+lTtViIsZcUHu9fdM4ZUUA9"
# }

variable "region" {
  description = "AWS region"
  default     = "af-south-1"
}


# variable "efs_storage_group" {
#   description = "EFS Security Group ID"
#   default = "sg-04f23db7618ef1863"
# }

# variable "efs_storage_access_point_id" {
#   description = "EFS access point ID"
#   default = "fsap-0f2a0b6b3f2f1a1d1"
# }
