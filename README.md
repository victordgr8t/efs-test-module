# AWS EFS Terraform Module

## Overview

This Terraform module provisions an AWS Elastic File System (EFS), which is a scalable, elastic, cloud-native file system for Linux OS. EFS is designed to provide massively parallel shared access to thousands of EC2 instances, enabling your applications to achieve high levels of aggregate throughput and IOPS with consistent low latencies.

The module sets up the file system and configures it with the necessary security and access parameters. It also includes an EC2 instance for demonstration purposes, which mounts the EFS file system.

## Features

- **EFS File System**: Provisions an encrypted EFS file system with configurable performance settings.
- **Mount Targets**: Creates mount targets in the specified subnets, allowing EC2 instances to access the EFS file system.
- **Access Points**: Optionally creates an access point to manage application access.
- **Backup Policy**: Attaches a backup policy to the EFS file system, ensuring data durability and compliance.
- **EC2 Instance**: Launches an EC2 instance and mounts the EFS file system for immediate use.

## How It Works

The module includes several Terraform files, each responsible for a part of the AWS EFS infrastructure:

- `main.tf`: Contains the core resource definitions for creating the EFS file system, mount targets, access points, backup policy, and an EC2 instance.
- `variables.tf`: Defines the variables used across the module to allow for customization and reusability.
- `outputs.tf`: Specifies the output values that can be used to retrieve important information after the module has been applied.
- `security-group.tf`: Manages the security groups that will be attached to the EFS mount targets and the EC2 instance for secure access.

## Security Group Configuration (`security-group.tf`)

Within the `security-group.tf` file, a dynamic block is used to configure ingress rules for a security group. This block dynamically creates ingress rules based on a provided list of CIDR blocks.

### Dynamic Ingress Block

The `dynamic "ingress"` block in Terraform allows for the creation of multiple ingress rules without having to declare each one separately. This is particularly useful when the number of ingress rules is dependent on a variable, such as a list of CIDR blocks that are allowed to access the resource.

### Configuration Details

- `for_each`: This argument iterates over the `var.whitelist_cidr` variable. If `var.whitelist_cidr` is empty, it defaults to an empty list `[]`, meaning no ingress rules will be created. Otherwise, it will create one ingress rule per CIDR block in the list.
- `content`: Inside the `content` block, the actual settings for each ingress rule are defined:

  - `cidr_blocks`: Specifies the CIDR blocks that are allowed access. This is set to the value of `var.whitelist_cidr`, which should be a list of string values representing the CIDR blocks.
  - `whitelist_sg`: The `whitelist_sg` variable is a list of security group IDs that are permitted to interact with the EFS file system. This variable is used to create security group rules that explicitly allow traffic from other AWS resources associated with these security groups.

  - `from_port` and `to_port`: These define the port range that the rule will apply to. Both are set to `local.port`, which as documented earlier, is the standard port for NFS (2049). This means that the ingress rule will allow traffic on port 2049.
  - `protocol`: The protocol for the rule is set to "tcp", which is the protocol used by NFS.

- `locals.tf`: The `locals.tf` file is used to define local variables within the Terraform module. These are convenient aliases for values that are repeated throughout the module and can be changed in a single place.
- `port`: This local variable is set to `2049`, which is the standard port number for the Network File System (NFS) protocol. AWS EFS uses this protocol for file sharing. By defining it as a local variable, we ensure consistency across all resources that require the NFS port and make our module more maintainable.

## Usage

To use this module in your Terraform environment, you will need to include it in your Terraform configuration file with the required variables. Here is an example of how to include this module:

```hcl
module "efs" {
  source = "git::https://@github.com/victordgr8t/bsa-modules-aws-migration-main.git//efs-module?ref=main"


  # Variables
  efs_name                        = var.efs_name
  vpc_id                          = var.vpc_id
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode
  encrypted                       = var.encrypted
  kms_key_id                      = var.kms_key_id
  tags                            = var.tags
  whitelist_cidr                  = var.whitelist_cidr
  efs_backup_policy_enabled       = var.efs_backup_policy_enabled
  ap_directory                    = var.ap_directory
  subnet_ids                      = var.subnet_ids
  owner_gid                       = var.owner_gid
  owner_uid                       = var.owner_uid
  ami                             = var.ami
  instance_type                   = var.instance_type
  key_name                        = var.key_name
}
```

'//efs-module' this refers to a specific file in the gitbub repository, also '?ref=main' refers to a specific branch, in this case main branch.

Local variables are referenced in Terraform code using the `local` prefix followed by the variable name. For example:

```hcl
dynamic "ingress" {
    for_each = length(var.whitelist_cidr) == 0 ? [] : var.whitelist_cidr
    content {
      cidr_blocks = var.whitelist_cidr
      from_port   = local.port
      to_port     = local.port
      protocol    = "tcp"
    }
}
```


When applied, this configuration will create a set of ingress rules that allow TCP traffic on the NFS port (2049) from the specified CIDR blocks. This is essential for enabling the necessary connectivity to the EFS file system from allowed IP ranges.


### Security Consideration

It is important to carefully manage the `var.whitelist_cidr` variable to ensure that only trusted IP ranges are given access to the EFS system, as this can be a critical aspect of the security posture for your infrastructure.

It is important to manage this variable with caution, as it controls network access to your EFS file system. Only security groups that require access should be included to maintain a strict security posture.

---

This dynamic approach to security group configuration allows for flexible and maintainable definitions of network access rules, adapting to the needs of your infrastructure as defined by your Terraform variables.



## Test EC2 Instance (OPTIONAL)

The module includes the provisioning of an AWS EC2 instance to demonstrate the interaction with the EFS file system. The instance is configured to mount the EFS upon startup.

### Configuration

The EC2 instance is created with the following configuration:

- **AMI**: The Amazon Machine Image ID is specified by the `ami` variable, which should be an image that supports the Amazon EFS utilities.
- **Instance Type**: Defined by the `instance_type` variable, it determines the size and capacity of the instance.
- **Key Name**: Specified by the `key_name` variable, it allows SSH access to the instance.
- **Subnet ID**: The instance is placed in the first subnet specified in the `subnet_ids` variable array.
- **Security Groups**: The instance is associated with the security group defined in `security-group.tf`, which should allow NFS traffic for EFS.

### User Data Script

The instance uses a user data script to perform the following actions upon launch:

1. Update the system packages.
2. Install the `amazon-efs-utils` package, which provides utilities for using EFS file systems.
3. Wait for 60 seconds to ensure that the network is up and the EFS file system is ready.
4. Create a directory at `/mnt/efs` to serve as the mount point for the EFS file system.
5. Mount the EFS file system to the `/mnt/efs` directory using the EFS ID and enabling encryption in transit (TLS).

Here is the user data script used:

```bash
#!/bin/bash
sudo yum update -y
sudo yum install -y amazon-efs-utils
sleep 60
sudo mkdir -p /mnt/efs
sudo mount -t efs -o tls [EFS_ID]:/ /mnt/efs
```

Replace [EFS_ID] with the actual ID or set variable "${aws_efs_file_system.efs_storage.id}" of the EFS file system that the module outputs.

## Tags
The instance is tagged with the name of the EFS file system, appended with '-instance' , to make it easily identifiable in the AWS console.

This EC2 instance serves as a test or example of how to set up an EC2 instance to work with an EFS file system. It is not intended for production use without further configuration and security measures.


## See variables.tf for all variables that can be entered.

## Requirements
Name	        Version
terraform	    >= 1.0
aws	            >= 5.0

## Providers
Name	        Version
aws	            >= 5.0


## Inputs
Inputs are documented in variables.tf and include descriptions of their purpose and default values.
variable "efs_name" {
  description = "value"
  type        = string
  default     = "ElasticFS_Storage"
}

variable "vpc_id" {
  description = "VPC ID for SG"
  type        = string
  default     = "vpc-xxx"
}


## Outputs
Outputs are documented in outputs.tf and include descriptions of their values.
output "efs_id" {
  value = module.efs.efs_id
}

output "mount_target_ips" {
  value = module.efs.mount_target_ips
}


## Resources
This module creates the following resources:

    AWS EFS File System
    AWS EFS Mount Target
    AWS EFS Access Point
    AWS Security Group
    AWS EC2 Instance (optional for testing)


For more details on the resources created, refer to the individual .tf files within the module.


## Authors
Module managed by Victor.


## Acknowledgements
This module is inspired by the work done by the terraform-aws-modules community.
````
