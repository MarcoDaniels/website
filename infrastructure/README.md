# Infrastructure

Website infrastructure is handled with [Terraform](https://www.terraform.io/).

- Build all lambdas with `nix-build` in `./lambda` 
- Output will be in `/result/{lambda-name}`
- Terraform picks, zips and applies lambdas