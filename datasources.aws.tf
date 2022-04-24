locals {
  create_s3_bootstrap_policy = !var.code_package_public && var.cloud_provider == "aws" && length(var.bootstrap_objectstorage_bucket_name) != 0
  use_aws_ubuntu_ami = var.operating_system == "ubuntu" && var.cloud_provider == "aws"
  use_aws_ebs_volumes = var.cloud_provider == "aws" && length(var.ebs_block_device) > 0
  ami_map = {
    ubuntu = {
      filters = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"]
      owners  = ["099720109477"]
    }
  }
}

#tflint-ignore: terraform_unused_declarations
data "aws_s3_bucket" "bootstrap" {
  count  = local.create_s3_bootstrap_policy ? 1 : 0
  bucket = var.bootstrap_objectstorage_bucket_name
}

# Lookup AMI
data "aws_ami" "ami" {
  for_each = { for k, v in { "ubuntu" = "os"} : k => v if local.use_aws_ubuntu_ami }

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
data "template_cloudinit_config" "node" {
  count = var.cloud_provider == "aws" ? 1 : 0

  gzip = false

  # TODO:  This will be getting modified to supply input to an external script
  #  I have to build the cardano-node-ansible repo out before modifying this to be accurate
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = <<-EOF
    #cloud-config
    packages: ${join("\n  -", var.cloudinit_packages)}
    runcmd: ${join("\n  -", var.cloudinit_runcmd)}
    write_files:
      - path: '/usr/local/bin/bootstrap.sh'
        permissions: '0755'
        owner: 'root:root'
        content: "IGNORE_ME"
    EOF
  }
}
