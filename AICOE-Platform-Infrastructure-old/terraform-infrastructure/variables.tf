# General variables
variable "region" {
  type        = string
  description = "aws region to deploy into"
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "aws_account_id"
  type        = string
}

variable "aws_profile" {
  description = "aws profile to use for credentials"
  type = string
  default = "default"
}

variable "team" {
  description = "team name for env to be created"
  type        = string
}

variable "gitops_branch" {
  type = string
}

# SSH key variables
variable "key_name"{
    type = string
}

variable "ssh_key"{
    type = string
    sensitive = true
}

# Ingress variables
variable "istio_dns" {
  type = string
}

variable "istio_cert" {
  type = string
}

variable "hosted_zone" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

# Bastion variables
variable "bastion_role" {
    type = string
}

# Autoscaling variables
# GPU node group
variable "gpu_instance_type" {
    default     = "p2.xlarge"
    type = string
}

variable "gpu_group_max" {
    default     = 3
    type = number
}

variable "gpu_group_min" {
    default     = 1
    type = number
}

variable "gpu_group_default" {
    default     = 1
    type = number
}

# Infrastructure node group
variable "infrastructure_instance_type" {
    default     = "m5.large"
    type = string
}

variable "infrastructure_group_max" {
    default     = 12
    type = number
}

variable "infrastructure_group_min" {
    default     = 3
    type = number
}

variable "infrastructure_group_default" {
    default     = 6
    type = number
}

# CPU (Worker) node group
variable "worker_instance_type" {
    default     = "m5.2xlarge"
    type = string
}

variable "worker_group_max" {
    default     = 12
    type = number
}

variable "worker_group_min" {
    default     = 0
    type = number
}

variable "worker_group_default" {
    default     = 1
    type = number
}

# Networking variables
variable "vpc_id" {
  description = "vpc id of vpc to deploy into"
  type = string
}

variable "vpc_cidr" {
  description = "cidr block of the vpc"
  type = string
}

variable "subnets" {
  description = "list of subnet ids to deploy into"
  type = list(string)
}

variable "subnets_cidr" {
  description = "not sure if needed"
  type = list(string)
}

variable "nonrouteable_subnets" {
  description = "nonrouteable_subnets"
  type        = list(string)
}

variable "nbculling" {
  type        = bool
  description = "Value for this variable should come from parameters.tfvars file ,If set to true indicates creation of nbculling resources"
  default     = "true"
}

variable "velero" {
  type        = bool
  description = "Value for this variable should come from parameters.tfvars file ,If set to true indicates creation of velero resources"
  default     = "true"
}

variable "platform_metadata_bucket_name" {
  type        = string
  description = "s3 bucket to store nbculling metadata"
}

variable tf_state_bucket {}

#s3 loki lifecycle variables
variable "apply_lifecycle_rule" {
  type        = bool
  description = "this will turn the lifecycle rule on or off"
  default     = true
}
variable "rule_coverage" {
  type        = string
  description = "this will determine which files to apply the lifecycle rule to, \"\" will apply it to all"
  default     = ""
}

# Alerting Variables
variable "alert_channel_webhook_url" {
  description = "Teams Channel Webhook URL"
  type = string
}