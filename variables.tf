variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
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
    error_message = "An invalid SSH key has been specified in \"var.ssh_public_key\".  Please check https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html for instructions."
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
    error_message = "Variable \"bootstrap_objectstorage_bucket_name\" does not meet AWS S3 Bucket naming rules.  Please check https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html."
  }
}
