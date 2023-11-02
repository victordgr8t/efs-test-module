output "ElasticFS_storage_dns_name" {
  value       = aws_efs_file_system.ElasticFS_Storage.dns_name
  description = "EFS DNS name"
}

output "ElasticFS_storage_id" {
  value       = aws_efs_file_system.ElasticFS_Storage.id
  description = "EFS ID"
}

output "ElasticFS_storage_arn" {
  value       = aws_efs_file_system.ElasticFS_Storage.arn
  description = "EFS ARN"
}

output "ElasticFS_storage_access_point_id" {
  value       = var.ap_directory != "" ? aws_efs_access_point.ElasticFS_Storage_access_point.id : null
  description = "EFS access point ID"
}

output "ElasticFS_storage_access_point_arn" {
  value       = var.ap_directory != "" ? aws_efs_access_point.ElasticFS_Storage_access_point.arn : null
  description = "EFS access point ARN"
}


