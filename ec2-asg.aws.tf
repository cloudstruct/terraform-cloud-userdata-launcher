locals {
  keypair_name = local.create_aws_key_pair ? aws_key_pair.ssh[0].key_name : var.ssh_key_pair
}

# Launch templates
resource "aws_launch_template" "node" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name_prefix   = "${var.name}-node"
  image_id      = data.aws_ami.ami[var.operating_system].image_id
  instance_type = var.instance_type
  key_name      = local.keypair_name

  update_default_version = var.aws_launch_template_update_default_version

  user_data = element(data.template_cloudinit_config.node, 1).rendered

  disable_api_termination = var.aws_instance_termination_protection

  vpc_security_group_ids = length(var.aws_security_group_ids) > 0 ? var.aws_security_group_ids : null

  iam_instance_profile {
    name = aws_iam_instance_profile.node[0].name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.root_block_volume_size_gb
      volume_type           = var.root_block_volume_type
      delete_on_termination = var.root_block_volume_delete_on_termination
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-node"
    },
  )
}

# Data EBS volumes
resource "aws_ebs_volume" "node_data" {
  for_each = {
    for key, val in toset(var.ebs_block_device) :
    key => val if local.use_aws_ebs_volumes
  }

  availability_zone = each.value.availability_zone
  encrypted         = lookup(each.value, "encrypted", null)
  iops              = lookup(each.value, "iops", null)
  kms_key_id        = lookup(each.value, "kms_key_id", null)
  size              = lookup(each.value, "volume_size", null)
  throughput        = lookup(each.value, "throughput", null)
  type              = lookup(each.value, "volume_type", null)

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-node"
    },
    lookup(each.value, "tags", {})
  )
}

# Autoscaling groups
# tflint-ignore: aws_resource_missing_tags
resource "aws_autoscaling_group" "node" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name = "${var.name}-node"

  desired_capacity = 1
  max_size         = 1
  min_size         = 1

  vpc_zone_identifier = var.instance_subnet_ids

  enabled_metrics = [
    "GroupInServiceInstances",
    "GroupTerminatingInstances",
  ]

  launch_template {
    id      = aws_launch_template.node[0].id
    version = "$Latest"
  }

  health_check_type = "EC2"

  dynamic "tag" {
    for_each = merge(
      var.tags,
      {
        Name = "${var.name}-node"
      },
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
