locals {
  create_iam_instance_profile = var.cloud_provider == "aws" && length(var.aws_instance_profile_role_name) > 0
}
resource "aws_iam_instance_profile" "node" {
  count = local.create_iam_instance_profile ? 1 : 0

  name = "${var.name}-node"
  role = var.aws_instance_profile_role_name

  tags = var.tags

}
