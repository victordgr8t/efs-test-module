variable "efs_name" {
  description = "value"
  type        = string
  default     = "ElasticFS_Storage"
}

variable "vpc_id" {
  description = "VPC ID for SG"
  type        = string
  default     = "vpc-01f8cf2855398cc3c"
}

variable "region" {
  description = "value of AWS region"
  default     = "eu-west-1"
}

variable "access_key" {
  type        = string
  description = "Access key of AWS"
  default     = "AKIAUJ62OUGNGRAGWQFL"

}

variable "secret_key" {
  type        = string
  description = "Secret Access key of AWS"
  default     = "UpEPdpS4BErAmrcDadXanGUOSCAljVKNFGUonNlF"

}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for mount target"
  default     = ["subnet-0eeed545965bcc422"]
}

variable "ami" {
  type        = string
  description = "AMI for EC2 instance"
  default     = "ami-06ed60ed1369448bd"

}

variable "instance_type" {
  type        = string
  description = "Instance type for EC2 instance"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "Key name for EC2 instance"
  default     = "my-key-pair"
}

variable "kms_key_id" {
  type        = string
  description = "The ARN for the KMS encryption key. When specifying kms_key_id, encrypted needs to be set to true"
  default     = null
}

variable "permissions" {
  description = "Specifies the POSIX permissions to apply to the root_directory"
  type        = string
  default     = "755"
}

variable "owner_gid" {
  description = "Specifies the POSIX group ID to apply to the root_directory"
  type        = number
  default     = 1000
}
variable "owner_uid" {
  description = "Specifies the POSIX user ID to apply to the root_directory"
  type        = number
  default     = 1000
}

variable "gid" {
  description = "Specifies the POSIX group ID to apply to the root_directory"
  type        = number
  default     = 1000
}

variable "uid" {
  description = "Specifies the POSIX user ID to apply to the root_directory"
  type        = number
  default     = 1000
}

variable "ap_directory" {
  description = "Create and directory to share using EFS access point"
  type        = string
  default     = "/testshare"
}

variable "whitelist_cidr" {
  description = "List of CIDR blocks for whitelist"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "whitelist_sg" {
  description = "List of Security Groups Block for whitelist"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "efs_backup_policy_enabled" {
  type        = bool
  description = "If `true`, it will turn on automatic backups."
  default     = false
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

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default = {
    env = "test"
  }
}

variable "availability_zone_id" {
  description = "The AZ ID where the mount target needs to be created"
  type        = string
  default     = "eu-west-1a"
}
