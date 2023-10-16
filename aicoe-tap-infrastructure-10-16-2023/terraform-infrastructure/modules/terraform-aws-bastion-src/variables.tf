variable "bucket_name" {
  description = "Bucket name were the bastion will store the logs"
}

variable "aws_account_id" {
  description = "aws_account_id"
  type        = string
}

variable "team" {
  description = "team deploying this bastion"
}

variable "bucket_versioning" {
  default     = true
  description = "Enable bucket versioning or not"
}

variable "bucket_force_destroy" {
  default     = true
  description = "The bucket and all objects should be destroyed when using true"
}

variable "tags" {
  description = "A mapping of tags to assign"
  default     = {}
  type        = map(string)
}

variable "region" {
}

variable "cidrs" {
  description = "List of CIDRs than can access to the bastion. Default : 0.0.0.0/0"
  type        = list(string)

  default = [
    "0.0.0.0/0",
  ]
}

variable "is_lb_private" {
  description = "If TRUE the load balancer scheme will be \"internal\" else \"internet-facing\""
}

variable "vpc_id" {
  description = "VPC id were we'll deploy the bastion"
}

variable "bastion_host_key_pair" {
  description = "Select the key pair to use to launch the bastion host"
}

variable "hosted_zone_id" {
  description = "Name of the hosted zone were we'll register the bastion DNS name"
  default     = ""
}

variable "bastion_record_name" {
  description = "DNS record name to use for the bastion"
  default     = ""
}

variable "bastion_launch_template_name" {
  description = "Bastion Launch template Name, will also be used for the ASG"
  default     = "bastion-lt"
}

variable "bastion_security_group_id" {
  description = "Custom security group to use"
  default     = ""
}

variable "bastion_host_role" {
  description = "IAM role .name to assign to bastion instance profile"
  default     = ""
}

variable "bastion_additional_security_groups" {
  description = "List of additional security groups to attach to the launch template"
  type        = list(string)
  default     = []
}

variable "bastion_ami" {
  type        = string
  description = "The AMI that the Bastion Host will use."
  default     = ""
}

variable "elb_subnets" {
  type        = list(string)
  description = "List of subnet were the ELB will be deployed"
}

variable "auto_scaling_group_subnets" {
  type        = list(string)
  description = "List of subnet were the Auto Scalling Group will deploy the instances"
}

variable "associate_public_ip_address" {
  default = false
}

variable "bastion_instance_count" {
  default = 1
}

variable "create_dns_record" {
  description = "Choose if you want to create a record name for the bastion (LB). If true 'hosted_zone_id' and 'bastion_record_name' are mandatory "
}

variable "log_auto_clean" {
  description = "Enable or not the lifecycle"
  default     = false
}

variable "log_standard_ia_days" {
  description = "Number of days before moving logs to IA Storage"
  default     = 30
}

variable "log_glacier_days" {
  description = "Number of days before moving logs to Glacier"
  default     = 60
}

variable "log_expiry_days" {
  description = "Number of days before logs expiration"
  default     = 90
}

variable "public_ssh_port" {
  description = "Set the SSH port to use from desktop to the bastion"
  default     = 22
}

variable "private_ssh_port" {
  description = "Set the SSH port to use between the bastion and private instance"
  default     = 22
}

variable "extra_user_data_content" {
  description = "Additional scripting to pass to the bastion host. For example, this can include installing postgresql for the `psql` command."
  type        = string
  default     = ""
}

variable "allow_ssh_commands" {
  description = "Allows the SSH user to execute one-off commands. Pass 'True' to enable. Warning: These commands are not logged and increase the vulnerability of the system. Use at your own discretion."
  type        = string
  default     = ""
}

variable "bastion_iam_policy_name" {
  description = "IAM policy name to create for granting the instance role access to the bucket"
  default     = "BastionHost"
}

variable "bastion_iam_permissions_boundary" {
  description = "IAM Role Permissions Boundary to constrain the bastion host role"
  default     = ""
}

variable "instance_type" {
  description = "Instance size of the bastion"
  default     = "t3.nano"
}

variable "disk_encrypt" {
  description = "Instance EBS encrypt"
  type        = bool
  default     = true
}

variable "disk_size" {
  description = "Root EBS size in GB"
  type        = number
  default     = 8
}

variable "enable_logs_s3_sync" {
  description = "Enable cron job to copy logs to S3"
  type        = bool
  default     = true
}

variable "subnets" {
type = list(string)
default = [""]
}

variable "cluster_security_group" {
type = string
default = ""
}

variable "subnets_cidr" {
  type = list(string)
}