variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "myInstance"
}

variable "cloud_provider" {
  description = "The cloud provider this module will be used against."
  type        = string
  default     = "aws"
  validation {
    condition     = contains(["aws"], var.cloud_provider)
    error_message = "Allowed values for input_parameter are \"aws\"."
  }
}

variable "create_ssh_keypair" {
  description = "Controls if SSH Keypair should be created."
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "If \"create_ssh_keypair\" is set to true, use this variable if you want to use a pre-existing SSH Public Key. If not specified a new one will be created."
  type        = string
  default     = ""
  validation {
    condition     = length(var.ssh_public_key) == 0 || can(regex("(AAAAB3NzaC1yc2EA|AAAAC3NzaC1lZDI1NTE5)", var.ssh_public_key))
    error_message = "An invalid SSH key has been specified in \"var.ssh_public_key\". Please check https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html for instructions."
  }
}

variable "ssh_key_pair" {
  description = "If \"create_ssh_keypair\" is set to false, use this variable to specify a pre-existing cloud key-pair. Mutually exclusive with \"create_ssh_keypair\"."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "key_pair_tags" {
  description = "Additional tags for the Key Pair"
  type        = map(string)
  default     = {}
}

variable "cloudinit_packages" {
  description = "A list of packages required by cloud-init to perform the software launch."
  type        = list(string)
  default = [
    "awscli",
    "jq",
    "unzip",
    "wget",
    "python3-pip",
    "python3-venv",
    "python3-docker",
  ]
}

variable "code_package_public" {
  description = "A boolean value which determines if the downloaded code package is a public URL or a private object storage URI requiring IAM privileges."
  type        = bool
  default     = true
}

variable "bootstrap_objectstorage_bucket_name" {
  description = "The name of the object storage bucket which contains the code package to execute on the node."
  type        = string
  default     = ""
  validation {
    condition     = length(var.bootstrap_objectstorage_bucket_name) == 0 || (length(var.bootstrap_objectstorage_bucket_name) > 2 && length(var.bootstrap_objectstorage_bucket_name) < 64 && lower(var.bootstrap_objectstorage_bucket_name) == var.bootstrap_objectstorage_bucket_name)
    error_message = "Variable \"bootstrap_objectstorage_bucket_name\" does not meet AWS S3 Bucket naming rules. Please check https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html."
  }
}

# TODO: This will get removed when bootstrapping is completed
#       which will come after cardano-node-ansible repo is ready
#tflint-ignore: terraform_unused_declarations
variable "bootstrap_objectstorage_file" {
  description = "The name of the object storage prefix and file which contains the code package to execute on the node. This file must be a gzipped tarball. (i.e. \"myPrefix/bootstrap.tar.gz\"). Note: This file will only be used if \"code_package_public\" is set to False."
  type        = string
  default     = "bootstrap.tar.gz"
}

# TODO: This will get removed when bootstrapping is completed
#       which will come after cardano-node-ansible repo is ready
#tflint-ignore: terraform_unused_declarations
variable "bootstrap_package_url" {
  description = "The URL to grab the bootstrap package from. This URL will only be used if \"code_package_public\" is set to True."
  type = string
  default = ""
  validation {
    condition = length(var.bootstrap_package_url) == 0 || length(var.bootstrap_package_url) > 5
    error_message = "Valid length check failed against variable \"var.bootstrap_package_url\". Please check supplied URL."
  }
}

variable "operating_system" {
  description = "The operating system to use for the servers."
  type        = string
  default     = "ubuntu"
  validation {
    condition = contains(["ubuntu"], var.operating_system)
    error_message = "Allowed values for operating_system are \"aws\"."
  }
}

variable "cloudinit_runcmd" {
  description = "The \"runcmd\" portion of cloud-init which will be used to execute your bootstrap scripts."
  type = list(string)
  default = [
    "/tmp/bootstrap/bootstrap.sh",
  ]
}

#tflint-ignore: terraform_unused_declarations
variable "instance_external_ip" {
  description = "Whether or not to provision the instance with an external IP address."
  type = bool
  default = false
}

variable "instance_subnet_ids" {
  description = "The cloud network subnet IDs to place the instance in."
  type = list(string)
  default = []
  validation {
    condition = length(var.instance_subnet_ids) > 0 && can([for subnet in var.instance_subnet_ids : regex("^subnet-.*", subnet)])
    error_message = "Valid Subnet ID Regex check failed against variable \"instance_subnet_ids\".  Please check supplied subnet IDs."
  }
}

variable "instance_type" {
  description = "The cloud VM instance type to use for this node."
  type = string
  default = "m6g.large"
  validation {
    condition = length(var.instance_type) > 1
    error_message = "Instance type failed length check.  Please ensure you are providing a valid instance type for your cloud provider."
  }
}

variable "aws_instance_profile_role_name" {
  description = "The AWS IAM role name to attach to the instance profile for the instance launched by this module."
  type = string
  default = ""
  validation {
    condition = length(var.aws_instance_profile_role_name) == 0 || (length(var.aws_instance_profile_role_name) < 65 && can(regex("[\\w+=,.@-]+", var.aws_instance_profile_role_name)))
    error_message = "Instance type failed length check.  Please ensure you are providing a valid instance type for your cloud provider."
  }
}

variable "aws_instance_termination_protection" {
  description = "Enable or disable AWS instance termination protection when using AWS as your cloud provider."
  type = bool
  default = false
}

variable "aws_launch_template_update_default_version" {
  description = "Enable or disable updating Launch Template default for AWS AutoScaling Group when updating Launch Template."
  type = bool
  default = true
}

variable "aws_security_group_ids" {
  description = "A list of AWS VPC Security group IDs to apply to the AutoScaling Group Launch Template."
  type = list(string)
  default = []
  validation {
    condition = length(var.aws_security_group_ids) == 0 || can([for s in var.aws_security_group_ids : regex("^([0-9]*/)?sg-([0-9]*)", s)])
    error_message = "One or more of the supplied security group IDs does not meet the regex validation. Please check provided Security Group IDs."
  }
}

variable "root_block_volume_size_gb" {
  description = "The size of the block volume hosting the root filesystem in Gigabytes."
  type = number
  default = 20
  validation {
    condition = var.root_block_volume_size_gb > 7
    error_message = "Variable \"root_block_volume_size_gb\" is either not a valid integer or is not greater than the minimum size of 8GB."
  }
}

variable "root_block_volume_type" {
  description = "The block volume type for the nodes root filesystem."
  type = string
  default = "gp3"
  validation {
    condition     = contains(["gp3","gp2"], var.root_block_volume_type)
    error_message = "Allowed values for variable \"root_block_volume_type\" are [\"gp2\", \"gp3\"]."
  }
}
variable "root_block_volume_delete_on_termination" {
  description = "Whether or not to terminate the root block volume when the instance it's attached to terminates."
  type = bool
  default = true
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = list(map(string))
  default     = []
}

#tflint-ignore: terraform_unused_declarations
variable "aws_route53_zone_arn" {
  description = "The AWS Route53 Zone ID to use for Service Discovery."
  type = string
  default = ""
  validation {
    condition     = length(var.aws_route53_zone_arn) == 0 || length(var.aws_route53_zone_arn) > 5
    error_message = "AWS Route53 Zone ARN does not appear to be a valid length for variable \"aws_route53_zone_arn\".  Please check supplied Route53 Zone ARN."
  }
}
