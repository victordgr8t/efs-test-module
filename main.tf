# Create EFS

resource "aws_efs_file_system" "efs_storage" {
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

resource "aws_efs_mount_target" "efs_storage_mount_target" {
  count = length(var.subnet_ids) #length(var.subnet_ids)

  file_system_id  = aws_efs_file_system.efs_storage.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.nfs_sg.id]

  depends_on = [
    aws_security_group.nfs_sg,
    aws_efs_file_system.efs_storage
  ]
}

resource "aws_efs_access_point" "efs_storage_access_point" {
  count = var.ap_directory != "" ? 1 : 0

  file_system_id = aws_efs_file_system.efs_storage.id
  root_directory {
    path = var.ap_directory
    creation_info {
      owner_gid   = var.owner_gid
      owner_uid   = var.owner_uid
      permissions = var.root_permissions
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.efs_name
    }
  )
}

# Create Backup for EFS
resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.efs_storage.id

  backup_policy {
    status = var.efs_backup_policy_enabled ? "ENABLED" : "DISABLED"
  }
}


resource "aws_instance" "efs_instance" {

  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = var.subnet_ids[0]
  security_groups = [aws_security_group.nfs_sg.id]

  associate_public_ip_address = true

  tags = merge(
    var.tags,
    {
      Name = "${var.efs_name}-instance"
    }
  )

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y amazon-efs-utils
              sleep 60
              sudo mkdir -p /mnt/efs
              sudo mount -t efs -o tls ${aws_efs_file_system.efs_storage.id}:/ /mnt/efs
              EOF
}
