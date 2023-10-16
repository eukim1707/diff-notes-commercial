output "aws_region" {
  value = var.region
}

output "aws_account_id" {
  value = var.aws_account_id
}

output "key_name" {
  value = var.key_name
}

output "istio_dns" {
  value = var.istio_dns
}

output "istio_cert" {
  value = var.istio_cert
}

output "hosted_zone" {
  value = var.hosted_zone
}

output "gitops_branch" {
  value = var.gitops_branch
}

output "client_id" {
  value = var.client_id
}

output "client_secret" {
  value = var.client_secret
}

output "bastion_dns" {
  value = module.bastion.elb_ip
}

output "cluster_name" {
  value = "${var.team}-eks-cluster"
}

output "team" {
  value = var.team
}

output "bucket_name" {
  value = module.bastion.bucket_name
}

output "security_group" {
  value = module.eks.cluster_security_group_id
}

output "routeable_subnet_1_id" {
    value = var.subnets[0]
}

output "routeable_subnet_2_id" {
    value = var.subnets[1]
}

output "nonrouteable_subnet_1_id" {
    value = var.nonrouteable_subnets[0]
}

output "nonrouteable_subnet_2_id" {
    value = var.nonrouteable_subnets[1]
}

output "gpu_group_max" {
    value = var.gpu_group_max
}

output "gpu_group_min" {
    value = var.gpu_group_min
}

output "gpu_group_default" {
    value = var.gpu_group_default
}

output "infrastructure_group_max" {
    value = var.infrastructure_group_max
}

output "infrastructure_group_min" {
    value = var.infrastructure_group_min
}

output "infrastructure_group_default" {
    value = var.infrastructure_group_default
}

output "worker_group_max" {
    value = var.worker_group_max
}

output "worker_group_min" {
    value = var.worker_group_min
}

output "worker_group_default" {
    value = var.worker_group_default
}

output "efs_filesystem_id" {
  value = module.eks.efs_filesystem_id
}

output "oidc_url" {
  value = module.eks.oidc_url
}

output "velero_status" {
  value = module.eks.velero_status
}

output "nbculling_status" {
  value = module.eks.nbculling_status
}

output "platform_metadata_bucket_name" {
  value = var.platform_metadata_bucket_name
}

output "apply_lifecycle_rule" {
  value = var.apply_lifecycle_rule
}

output "alert_channel_webhook_url" {
  value = var.alert_channel_webhook_url
}