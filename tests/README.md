# Testing
This directory will contain tfvars used for testing as well as simple terraform code to create any required objects for tests to pass.
There may be exceptions to this where cost comes into play.

## Build AWS Testing Objects
In this directory execute `terraform plan -var-file="aws-testing.tfvars"`
