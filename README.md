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

# What's next?
### Deploying k8s on CentOS with Ansible

Provided terraform configuration will deploy the following VM:

````
name            IP                    
ansible         192.168.192.158
k8s-ctrl        192.168.192.159
k8s-wrk-1       192.168.192.150
k8s-wkr-2       192.168.192.151
````

## Steps:
1. Install ansible using [`script`](https://github.com/eremenkog/proxmox-terraform/blob/main/ansible/configs/ansible_install.sh)
```bash
sudo su
dnf -y install ansible-core 
mv /etc/ansible/ansible.cfg /etc/ansible/ansible.cfg.org
ansible-config init --disabled > /etc/ansible/ansible.cfg 

sudo sed -i 's/;host_key_checking=True/host_key_checking=False/' /etc/ansible/ansible.cfg
```
2. Configure ansible hosts or use [provided one](https://github.com/eremenkog/proxmox-terraform/blob/main/ansible/configs/hosts)
``` bash
[k8s_ctrls]
192.168.192.159		ansible_connection=ssh

[k8s_workers]
192.168.192.100		ansible_connection=ssh
192.168.192.101		ansible_connection=ssh
```
3. Use provided playbook to setup control plane
```bash
ansible-playbook k8s-centos-controller-install.yaml
```
4. Setup worker nodes & join them to cluster
```bash
ansible-playbook k8s-centos-worker-install.yaml
ansible-playbook k8s-centos-worker-join.yaml
```