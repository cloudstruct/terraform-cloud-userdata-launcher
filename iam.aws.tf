resource "aws_iam_role" "node" {
  count = var.cloud_provider == "aws" ? 1 : 0

  # TODO: put 'node' before 'each.key' for consistency
  # This is disruptive, because it will destroy the IAM role for the running instances
  name = "${var.name}-node"

  assume_role_policy = element(data.aws_iam_policy_document.assume_role, 1).json

  # Not all nodes have a matching ebs-attach policy, so we use dynamic blocks
  # to make it conditional
  dynamic "inline_policy" {
    for_each = {
      for key, val in { "create_ebs_policy" = "true" } :
      key => val if local.use_aws_external_ip
    }

    content {
      name   = "ebs-attach"
      policy = element(data.aws_iam_policy_document.ebs_attach, 1).json
    }
  }

  inline_policy {
    name   = "route53-update"
    policy = element(data.aws_iam_policy_document.route53_update, 1).json
  }

  # Not all configurations are using a bootstrap bucket, use dynamic block
  # to make it conditional
  dynamic "inline_policy" {
    for_each = {
      for key, val in { "create_s3bootstrap_policy" = "true" } :
      key => val if local.create_s3_bootstrap_policy
    }

    content {
      name   = "s3-bootstrap"
      policy = element(data.aws_iam_policy_document.s3_bootstrap, 1).json
    }
  }

  # Not all nodes have a matching eip-attach policy, so we use dynamic blocks
  # to make it conditional
  dynamic "inline_policy" {
    for_each = {
      for key, val in { "create_eip_policy" = "true" } :
      key => val if local.use_aws_external_ip
    }

    content {
      name   = "eip-attach"
      policy = element(data.aws_iam_policy_document.eip_attach, 1).json
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-node"
    },
  )
}

resource "aws_iam_instance_profile" "node" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name = "${var.name}-node"
  role = aws_iam_role.node[0].name

  tags = var.tags

}
