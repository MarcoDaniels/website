# Infrastructure

Website infrastructure is handled with [Terraform](https://www.terraform.io/).

Build with `nix-build` will output lambda in `/result`. Terraform picks, zips and applies lambdas.