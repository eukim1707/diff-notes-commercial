# GENERAL VARIABLES
variable "aws_account_id" {
  description = "aws_account_id"
  type        = string
}

variable "region" {
  type        = string
  description = "Default Region For Terraform"
}

variable "team" {
  type        = string
  description = "team"
}

# NETWORK VARIABLES
variable "vpc_id" {
  type        = string
  description = "vpc ID to add groups into"
}

variable "vpc_cidr" {
  type        = string
  description = "vpc cidr to add groups into"
}

variable "private_subnets" {
  type        = list(any)
  description = "list of private subnets"
}

variable "oidc_thumbprint_list" {
  type = list(string)
  default = [] 
}

# NODE GROUP VARIABLES
# workers
variable "worker_ami_type" {
    type = string
    default = "AL2_x86_64"
}
variable "worker_instance_type" {
    type = string
} 
variable "worker_group_max" {
    type = number
}
variable "worker_group_min" {
    type = number
}
variable "worker_group_default" {
    type = number
}
variable "worker_disk_size" {
    type = number
    default = 100
}
variable "worker_capacity_type" {
    type = string
    default = "ON_DEMAND"
}

# gpus
variable "gpu_ami_type" {
    type = string
    default = "AL2_x86_64_GPU"
}
variable "gpu_instance_type" {
    type = string
} 
variable "gpu_group_max" {
    type = number
}
variable "gpu_group_min" {
    type = number
}
variable "gpu_group_default" {
    type = number
}
variable "gpu_disk_size" {
    type = number
    default = 50
}
variable "gpu_capacity_type" {
    type = string
    default = "ON_DEMAND"
}

# infrastructure
variable "infrastructure_ami_type" {
    type = string
    default = "AL2_x86_64"
}
variable "infrastructure_instance_type" {
    type = string
} 
variable "infrastructure_group_max" {
    type = number
}
variable "infrastructure_group_min" {
    type = number
}
variable "infrastructure_group_default" {
    type = number
}
variable "infrastructure_disk_size" {
    type = number
    default = 50
}
variable "infrastructure_capacity_type" {
    type = string
    default = "ON_DEMAND"
}