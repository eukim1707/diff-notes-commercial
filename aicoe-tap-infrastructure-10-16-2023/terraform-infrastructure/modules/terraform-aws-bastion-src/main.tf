### Create KMS Resources ###
resource "aws_kms_key" "key" {
  tags = merge(var.tags)
  enable_key_rotation = true
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${replace(var.bucket_name, ".", "_")}"
  target_key_id = aws_kms_key.key.arn

}

data "aws_kms_alias" "kms-ebs" {
  name = "alias/aws/ebs"
}

### Create S3 Bucket and Bucket Policy ###
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  force_destroy = var.bucket_force_destroy

  versioning {
    enabled = var.bucket_versioning
  }

  lifecycle_rule {
    id      = "log"
    enabled = var.enable_logs_s3_sync && var.log_auto_clean
    prefix = "bastion_logs/"

    tags = {
      rule      = "log"
      autoclean = var.log_auto_clean
    }

    transition {
      days          = var.log_standard_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.log_glacier_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.log_expiry_days
    }
  }

  tags = merge(var.tags)

  lifecycle {
    ignore_changes = [logging,tags]
  }

}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Id": "SecurePolicy",
    "Statement": [
        {
            "Sid": "AllowSSLRequestsOnly",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "${aws_s3_bucket.bucket.arn}",
                "${aws_s3_bucket.bucket.arn}/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
  }
  POLICY

}

### Create Bastion Security Group and Security Group Rules ###
resource "aws_security_group" "bastion_host_security_group" {
  count       = var.bastion_security_group_id == "" ? 1 : 0
  description = "Enable SSH access to the bastion host from external via SSH port"
  name        = "${local.name_prefix}-host"
  vpc_id      = var.vpc_id

  tags = merge(var.tags)

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_security_group_rule" "ingress_bastion" {
  count       = var.bastion_security_group_id == "" ? 1 : 0
  description = "Incoming traffic to bastion"
  type        = "ingress"
  from_port   = var.public_ssh_port
  to_port     = var.public_ssh_port
  protocol    = "TCP"
  cidr_blocks = ["10.0.0.0/8"]

  security_group_id = local.security_group
}

resource "aws_security_group_rule" "egress_bastion" {
  count       = var.bastion_security_group_id == "" ? 1 : 0
  description = "Outgoing traffic from bastion to instances"
  type        = "egress"
  from_port   = "0"
  to_port     = "65535"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = local.security_group
}

resource "aws_security_group" "private_instances_security_group" {
  description = "Enable SSH access to the Private instances from the bastion via SSH port"
  name        = "${local.name_prefix}-priv-instances"
  vpc_id      = var.vpc_id

  tags = merge(var.tags)

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_security_group_rule" "ingress_instances" {
  description = "Incoming traffic from bastion"
  type        = "ingress"
  from_port   = var.private_ssh_port
  to_port     = var.private_ssh_port
  protocol    = "TCP"

  source_security_group_id = local.security_group

  security_group_id = aws_security_group.private_instances_security_group.id
}

data "aws_iam_policy_document" "assume_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

### Create Bastion IAM Role and Policies ###
resource "aws_iam_role" "bastion_host_role" {
  path                 = "/"
  assume_role_policy   = data.aws_iam_policy_document.assume_policy_document.json
  permissions_boundary = var.bastion_iam_permissions_boundary

  lifecycle {
    ignore_changes = [permissions_boundary]
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "bastion_host_policy_document" {

  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["${aws_s3_bucket.bucket.arn}/bastion_logs/*"]
  }

  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [
    aws_s3_bucket.bucket.arn]

  }

  statement {
    actions = [

      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = [aws_kms_key.key.arn]
  }

  statement {
    actions   = ["eks:*"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"]
    resources = [
      "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/aws/*",
      "arn:aws:ssm:*::parameter/aws/*"]
  }

  statement {
    actions   = ["kms:CreateGrant", "kms:DescribeKey"]
    resources = ["*"]
  }

  # allow IAM access for eksctl
  statement {
    actions = ["iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:GetRole",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy",
      "iam:ListInstanceProfiles",
      "iam:AddRoleToInstanceProfile",
      "iam:ListInstanceProfilesForRole",
      "iam:PassRole",
      "iam:DetachRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:GetOpenIDConnectProvider",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:ListAttachedRolePolicies",
    "iam:TagRole"]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/eksctl-*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eksctl-*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/eks-nodegroup.amazonaws.com/AWSServiceRoleForAmazonEKSNodegroup",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eksctl-managed-*"
    ]
  }

  statement {
    actions   = ["iam:GetRole"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"]
  }

  statement {
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]
    condition {
      test     = "ForAnyValue:StringEquals"
      values   = ["eks.amazonaws.com",
                "eks-nodegroup.amazonaws.com",
                "eks-fargate.amazonaws.com"]
      variable = "iam:AWSServiceName"
    }
  }
}

resource "aws_iam_policy" "bastion_host_policy" {
  name   = var.bastion_iam_policy_name
  policy = data.aws_iam_policy_document.bastion_host_policy_document.json
}

resource "aws_iam_role_policy_attachment" "bastion_host_custom_policy" {
  policy_arn = aws_iam_policy.bastion_host_policy.arn
  role       = aws_iam_role.bastion_host_role.name
  depends_on = [
    aws_iam_role_policy_attachment.bastion_host_ec2_all_access,
    aws_iam_role_policy_attachment.bastion_host_cloudformation_all_access
  ]
}

resource "aws_iam_role_policy_attachment" "bastion_host_ec2_all_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.bastion_host_role.name
}

resource "aws_iam_role_policy_attachment" "bastion_host_cloudformation_all_access" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
  role       = aws_iam_role.bastion_host_role.name
}

### Create Route53 Resources IF create_dns_records is True ###
resource "aws_route53_record" "bastion_record_name" {
  name    = var.bastion_record_name
  zone_id = var.hosted_zone_id
  type    = "A"
  count   = var.create_dns_record ? 1 : 0

  alias {
    evaluate_target_health = true
    name                   = aws_lb.bastion_lb.dns_name
    zone_id                = aws_lb.bastion_lb.zone_id
  }
}

### Create NLB Resources as Disaster Recovery Solution for Bastion ###
resource "aws_lb" "bastion_lb" {
  internal = var.is_lb_private
  name     = "${local.name_prefix}-lb"

  subnets = var.elb_subnets

  load_balancer_type = "network"
  tags               = merge(var.tags)
  
  lifecycle {
    ignore_changes = [access_logs[0].enabled]
  }
}

resource "aws_lb_target_group" "bastion_lb_target_group" {
  name        = "${local.name_prefix}-lb-target"
  port        = var.public_ssh_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    port     = "traffic-port"
    protocol = "TCP"
  }

  tags = merge(var.tags)
}

resource "aws_lb_listener" "bastion_lb_listener_22" {
  default_action {
    target_group_arn = aws_lb_target_group.bastion_lb_target_group.arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.bastion_lb.arn
  port              = var.public_ssh_port
  protocol          = "TCP"
}

### Create Bastion and Autoscaling Group ###
resource "aws_iam_instance_profile" "bastion_host_profile" {
  role = var.bastion_host_role
  path = "/"
}

resource "aws_launch_template" "bastion_launch_template" {
  name_prefix            = local.name_prefix
  image_id               = var.bastion_ami != "" ? var.bastion_ami : data.aws_ami.amazon-linux-2.id
  instance_type          = var.instance_type
  update_default_version = true
  key_name = var.bastion_host_key_pair

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = concat([local.security_group], var.bastion_additional_security_groups)
    delete_on_termination       = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.bastion_host_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.disk_size
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = var.disk_encrypt
      kms_key_id            = var.disk_encrypt ? data.aws_kms_alias.kms-ebs.target_key_arn : ""
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(tomap({ "Name" = var.bastion_launch_template_name }), merge(var.tags))
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(tomap({ "Name" = var.bastion_launch_template_name }), merge(var.tags))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion_auto_scaling_group" {
  name_prefix = "ASG-${local.name_prefix}"

  launch_template {
    id      = aws_launch_template.bastion_launch_template.id
    version = "$Latest"
  }
  
  max_size         = var.bastion_instance_count
  min_size         = var.bastion_instance_count
  desired_capacity = var.bastion_instance_count

  vpc_zone_identifier = var.auto_scaling_group_subnets

  default_cooldown          = 180
  health_check_grace_period = 180
  health_check_type         = "EC2"

  target_group_arns = [
    aws_lb_target_group.bastion_lb_target_group.arn,
  ]

  termination_policies = [
    "OldestLaunchConfiguration",
  ]

  tags = concat(
    tolist([tomap({
      "key"                 = "Name"
      "value"               = "ASG-${local.name_prefix}"
      "propagate_at_launch" = true
    })]),
    local.tags_asg_format
  )

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_s3_bucket.bucket]
}
