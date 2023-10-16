# Stack settings

# General information
team = "<name of team>" #(NOTE: ensure team name is less than 8 characters)
region =  "<region for deployment>"
aws_account_id = "<AWS account ID for deployment>" #(NOTE: 12-digit number, that uniquely identifies your AWS account. On your aws console check the navigation bar on the upper right)
aws_profile = "default"
gitops_branch = "<name of branch for AICOE-Platform-Gitops repo to be used for platform deployment>"

# Security information
key_name = "<unique key name of SSH key generated on your workstation>" #(NOTE: this key should be placed in the ~/.ssh folder and will be used to access the bastion host)
bastion_role = "<existing IAM role for bastion host>" #(NOTE: this role is also referenced in terraform.tf)

# Ingress information
istio_dns = "<dns record name for kubeflow UI that is associated with previously created ACM cert for this record, ex. dev>"
istio_cert = "<identifier of public ACM certificate for istio_dns record>"
hosted_zone = "<domain name of hosted zone in Route 53>"
client_id = "<App Client ID for registered application>"
client_secret = "<App Secret for registered application>"

# Autoscaling information
gpu_instance_type = "p2.xlarge" #(NOTE: instance type for GPU instances of cluster)
gpu_group_max = 1
gpu_group_min = 1
gpu_group_default = 1
infrastructure_instance_type = "m5.4xlarge" #(NOTE: instance type for infrastructure-specific workloads)
infrastructure_group_max = 12
infrastructure_group_min = 3
infrastructure_group_default = 3
worker_instance_type = "m5.8xlarge" #(NOTE: instance type for CPU instances of cluster)
worker_group_max = 12
worker_group_min = 1
worker_group_default = 1

# Network information
vpc_id = "<ID of your VPC>" #(NOTE: This can be found on the VPC details page that you get when selecting your VPC in the VPC section of the AWS console)
vpc_cidr = "<CIDR of your VPC>"
subnets = [
  "<ID of routeable subnet in first availability zone, ie. us-east-1a>", #(NOTE: This can be found in the Subnets page of the AWS console)
  "<ID of routeable subnet in second availability zone, ie. us-east-1b>",
]
subnets_cidr = [
  "<CIDR of routeable subnet in first availability zone, ie. us-east-1a>",
  "<CIDR of routeable subnet in second availability zone, ie. us-east-1b>",
]
nonrouteable_subnets = [
  "<ID of nonrouteable subnet in first availability zone, ie. us-east-1a>",
  "<ID of nonrouteable subnet in second availability zone, ie. us-east-1b>",
]

#External Application
nbculling = true # false in case if you don't want to enable the functionality
velero = true # false in case if you don't want to enable the functionality
platform_metadata_bucket_name = "<<s3_bucket_to_store_inbuilt_apps_template/logs>>" # Used for nbculling and velero

#s3 lifecycle rules
apply_lifecycle_rule = true # this will turn the lifecycle rule on or off (applies to velero, nbculling and loki buckets)

# Webhook Channel Configuration
alert_channel_webhook_url = "Add Teams Channel Webhook URL Here"
