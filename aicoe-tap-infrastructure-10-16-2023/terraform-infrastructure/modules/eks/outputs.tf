output "cluster_security_group_id" {
  value = aws_security_group.eks_cluster_sg.id
}

output "efs_filesystem_id" {
  value = aws_efs_file_system.efs_fs.id
}

output "oidc_url" {
  value = local.oidc_provider
}