# proxmox-terraform
# Overview

Example of a IaC deployment using `Proxmox Virtual Environment 8.2`


# Prequisites

1. Have [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) installed
2. Have [Proxmox](https://www.proxmox.com/en/) installed
3. Create templates with desired OS
4. Create necessary ssh keys if you wish to use them (up to 2 recommended, 1 for template VMs, 1 for deployed VMs)


# Steps
1. Create and configure Terraform user and role
2. Create a template with desired OS
3. Configure Terraform variables and test connection
4. Deploy using Terraform

# In-depth guide

## 1. Create and configure Terraform user and role.
Copy and run Terraform role preparation [`script`](https://github.com/eremenkog/proxmox-terraform/blob/main/proxmox/proxmox-add-terraform-user-role.sh) on Proxmox server. This will create terraform-prov user and TerraformProv role. You will be prompted for password.
```bash
bash proxmox-add-terraform-user-role.sh
```
## 2. Create a template with desired OS
Manually, or using [`script`](https://github.com/eremenkog/proxmox-terraform/blob/main/proxmox/proxmox-add-template_v3.sh).
You will be prompted for necessary input (such as template name) and optional choices (adding user, ssh key):

```bash
bash proxmox-add-terraform-user-role.sh
```
## 3. Configure Terraform variables and test connection
1. Populate variables.tf with your "proxmox_provider" values. 
``` tf
variable "proxmox_provider" {
  default = {
    pm_api_url = "https://#####:8006/api2/json"
    pm_user      = "terraform-prov@pve"
    pm_password  = "##################"
            }
}
```
At this point you can test connection with provider using
```
terraform plan
```
2. Make sure that the name of your template created in step 2 exists in "template_names"
3. Correct main.tf in a way you see fit.

## 4. Deploy using Terraform
```
terraform plan
terraform apply
```