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


# IAM role for lambdax
resource "aws_iam_role" "lambda_role" {
  name               = "terraform_aws_lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM policy for logging from a lambda

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
            "Sid": "AllowDeletePolicyVersion",
            "Effect": "Allow",
            "Action": "iam:DeletePolicyVersion",
            "Resource": "arn:aws:iam::296274010522:policy/aws_iam_policy_for_terraform_aws_lambda_role"
        },

    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "iam:DeletePolicy"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_efs" {
  name        = "LambdaEFSAccess"
  description = "Allow Lambda to access EFS"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowLambdaAccessToEFS",
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_efs_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_efs.arn
}


# Policy Attachment on the role.

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

data "aws_iam_policy_document" "lambda_ec2_permissions" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_ec2_policy" {
  name        = "LambdaEC2Permissions"
  description = "Allow Lambda to manage ENIs for VPC access"
  policy      = data.aws_iam_policy_document.lambda_ec2_permissions.json
}

resource "aws_iam_role_policy_attachment" "lambda_ec2_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_ec2_policy.arn
}


# Generates an archive from content, a file, or a directory of files.

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/efs-lambda-test.zip"
}

# Create a lambda function
# In terraform ${path.module} is the current directory.
resource "aws_lambda_function" "terraform_lambda_func" {
  filename      = "${path.module}/python/efs-lambda-test.zip"
  function_name = "EFS-Lambda-Function"
  description   = "Testing Lambda Function for EFS File Storage"
  role          = aws_iam_role.lambda_role.arn
  handler       = "efs-lambda-test.lambda_handler"
  runtime       = "python3.8"

  depends_on = [aws_efs_mount_target.ElasticFS_Storage_mount_target]

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.efs_sg.id]
  }

  file_system_config {
    arn              = aws_efs_access_point.ElasticFS_Storage_access_point.arn
    local_mount_path = "/mnt/efs"
  }
}



