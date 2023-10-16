data "aws_caller_identity" "current" {}

# EKS cluster
module "eks" {
  source          = "./modules/eks"
  region          = var.region
  aws_account_id  = var.aws_account_id
  vpc_id          = var.vpc_id
  vpc_cidr        = var.vpc_cidr
  team            = var.team
  private_subnets = var.subnets
  nbculling       = var.nbculling
  velero          = var.velero
  platform_metadata_bucket_name = var.platform_metadata_bucket_name
  tf_state_bucket = var.tf_state_bucket

  # Autoscaling inputs for GPU node group
  gpu_instance_type = var.gpu_instance_type
  gpu_group_max     = 1
  gpu_group_min     = 0
  gpu_group_default = 0

  # Autoscaling inputs for Infrastructure node group
  infrastructure_instance_type = var.infrastructure_instance_type
  infrastructure_group_max     = 1
  infrastructure_group_min     = 0
  infrastructure_group_default = 0

  # Autoscaling inputs for CPU (Worker) node group
  worker_instance_type = var.worker_instance_type
  worker_group_max     = 1
  worker_group_min     = 0
  worker_group_default = 0
}

resource "aws_key_pair" "bastion_access" {
  key_name   = "${var.key_name}"
  public_key = "${var.ssh_key}"
}

module "bastion" {
  source                     = "./modules/terraform-aws-bastion-src"
  region                     = var.region
  team                       = var.team
  aws_account_id             = var.aws_account_id
  vpc_id                     = var.vpc_id
  subnets                    = var.nonrouteable_subnets
  subnets_cidr               = var.subnets_cidr
  auto_scaling_group_subnets = var.subnets

  # Bastion specs
  bastion_launch_template_name = "${var.team}-bastion-lt"
  instance_type                = "t2.medium"
  disk_size                    = 100
  bastion_host_role            = var.bastion_role
  bastion_iam_policy_name      = "${var.team}-bastion-host-policy"
  cluster_security_group       = module.eks.cluster_security_group_id
  bastion_host_key_pair        = aws_key_pair.bastion_access.key_name
  allow_ssh_commands           = "True"

  # S3
  bucket_name         = "loki-${var.team}-logs"
  enable_logs_s3_sync = false
  create_dns_record   = false

  #lifecycle rules
  log_auto_clean = var.apply_lifecycle_rule
  log_name = "loki-${var.team}-logs" 
  
  # ELB specs
  elb_subnets   = var.subnets
  is_lb_private = true #false

  tags = {
    team = var.team
  }
}