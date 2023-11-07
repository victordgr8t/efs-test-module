output "efs_storage_dns_name" {
  value       = aws_efs_file_system.efs_storage.dns_name
  description = "EFS DNS name"
}

output "efs_storage_id" {
  value       = aws_efs_file_system.efs_storage.id
  description = "EFS ID"
}

output "efs_storage_arn" {
  value       = aws_efs_file_system.efs_storage.arn
  description = "EFS ARN"
}

output "efs_storage_access_point_id" {
  value       = var.ap_directory != "" ? aws_efs_access_point.efs_storage_access_point[0].id : null
  description = "EFS access point ID"
}

output "efs_storage_access_point_arn" {
  value       = var.ap_directory != "" ? aws_efs_access_point.efs_storage_access_point[0].arn : null
  description = "EFS access point ARN"
}

output "efs_security_group" {
  value       = aws_security_group.nfs_sg.id
  description = "EFS Security Group ID"
}


