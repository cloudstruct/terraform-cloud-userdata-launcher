locals {
  create_s3_bootstrap_policy = !var.code_package_public && var.cloud_provider == "aws" && length(var.bootstrap_objectstorage_bucket_name) != 0
  use_aws_ubuntu_ami         = var.operating_system == "ubuntu" && var.cloud_provider == "aws"
  use_aws_external_ip        = var.cloud_provider == "aws" && var.instance_external_ip
  use_aws_ebs_volumes        = var.cloud_provider == "aws" && length(var.ebs_block_device) > 0
  ami_map = {
    ubuntu = {
      filters = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"]
      owners  = ["099720109477"]
    }
  }
}

data "aws_iam_policy_document" "assume_role" {
  count = var.cloud_provider == "aws" ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Policy allowing updating of Route53 records in internal zone
data "aws_iam_policy_document" "route53_update" {
  count = var.cloud_provider == "aws" ? 1 : 0

  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [
      var.aws_route53_zone_arn,
    ]
  }
}

# Policy allowing fetching code package from S3
data "aws_iam_policy_document" "s3_bootstrap" {
  count = local.create_s3_bootstrap_policy ? 1 : 0

  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${element(data.aws_s3_bucket.bootstrap, 1).arn}/*",
    ]
  }
}

data "aws_s3_bucket" "bootstrap" {
  count  = local.create_s3_bootstrap_policy ? 1 : 0
  bucket = var.bootstrap_objectstorage_bucket_name
}

# Lookup AMI
data "aws_ami" "ami" {
  for_each = { for k, v in { "ubuntu" = "os" } : k => v if local.use_aws_ubuntu_ami }

  most_recent = true

  filter {
    name   = "name"
    values = local.ami_map[each.key].filters
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical
  owners = local.ami_map[each.key].owners
}

# Cloud-init config template
data "cloudinit_config" "node" {
  count = var.cloud_provider == "aws" ? 1 : 0

  gzip          = false
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = var.cloudinit_content
  }
}

# Policy allowing attaching the node's EBS volume
data "aws_iam_policy_document" "ebs_attach" {
  count = local.use_aws_ebs_volumes ? 1 : 0

  statement {
    actions = [
      "ec2:AttachVolume",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"

      values = [
        "${var.name}-node",
      ]
    }
  }

  statement {
    actions = [
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeStatus",
    ]

    resources = [
      "*",
    ]
  }
}

# Policy allowing attaching the node's EIP
data "aws_iam_policy_document" "eip_attach" {
  count = local.use_aws_external_ip ? 1 : 0

  statement {
    actions = [
      "ec2:AssociateAddress",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"

      values = [
        "${var.name}-node",
      ]
    }
  }

  # TODO: narrow the scope
  statement {
    actions = [
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
    ]

    resources = [
      "*",
    ]
  }
}
