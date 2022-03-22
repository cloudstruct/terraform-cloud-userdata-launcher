locals {
  create_new_ssh_key = var.create_ssh_keypair && (length(var.ssh_public_key) > 0)
}

# Generate SSH keypair
resource "tls_private_key" "generated_ssh_key_pair" {
  count     = local.create_new_ssh_key ? 1 : 0
  algorithm = "RSA"
}

resource "aws_key_pair" "ssh" {
  count = var.create_ssh_keypair ? 1 : 0

  key_name_prefix = var.name
  public_key      = try(tls_private_key.generated_ssh_key_pair[0].public_key_openssh, var.ssh_public_key)

  tags = merge(
    { "Name" = var.name },
    var.tags,
    var.key_pair_tags,
  )
}
