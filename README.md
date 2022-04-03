# Cardano Staking Pool Terraform Module
Terraform module which creates required infrastructure to launch a cloud 'instance' (Virtual Machine) and runs cloud-init based on input provided to this module.

## Usage
```
Fill me
```

## Examples
List examples here from `examples/` directory

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/cloudstruct/terraform-cloud-cardano-staking-pool/issues/new) section.

## Requirements
| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.63 |

## Testing
### AWS
Inside this directory execute
`terraform plan -var-file="tests/aws-testing.tfvars" -compact-warnings`

## Authors
Module is maintained by [CloudStruct](https://github.com/cloudstruct) with help from [these awesome contributors](https://github.com/cloudstruct/terraform-cloud-cardano-staking-pool/graphs/contributors).


## License
Apache 2 Licensed. See [LICENSE](https://github.com/cloudstruct/terraform-cloud-cardano-staking-pool/tree/master/LICENSE) for full details.
