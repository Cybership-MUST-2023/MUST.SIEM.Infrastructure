# Terraform infrastructure 

This document guides you through setting up a Proxmox virtual infrastructure through Terraform.
It is not meant as a guide for setting up Proxmox itself, and assumes a Proxmox environment is already created.
To learn more about Proxmox, I recommend [Learn Linux TV - Proxmox VE full course](https://www.youtube.com/watch?v=LCjuiIswXGs&list=PLT98CRl2KxKHnlbYhtABg6cF50bYa8Ulo).

## Table of contents

1. [Proxmox](#proxmox)
2. [Environment variables](#environment-variables)
3. [Terraform](#terraform)

## Proxmox

Once your Proxmox-server is installed, you'll need to do the following:
* [Set up the API key](#set-up-the-api-key)
* [Set up an Ubuntu cloud-init image](#set-up-an-ubuntu-cloud-init-image)

For more information on the user and group creation process, see the following [Learn Linux TV tutorial](https://youtu.be/frnILOGmATs?list=PLT98CRl2KxKHnlbYhtABg6cF50bYa8Ulo).

### Set up the API key

Terraform requires either a user or an API key with appropriate permissions. 
The script [add_API_user](/proxmox/add_API_user.sh) creates a user and an API key. 

Copy the contents of the [add_API_user](/proxmox/add_API_user.sh)-script to the Proxmox-server,
either through an SSH-connection or the VE-webinterface (select the node, then select *Shell*).
Execute the following commands:

```Bash
nano add_API_user.sh
chmod +x add_API_user.sh
./add_API_user.sh
```
Enter a strong password and a (randomly generated[^5]) API Token ID[^9].
**Be sure to save the API Token Secret, which is output by the script!**

To use the API token, set the HTTP header *Authorization* to the displayed value of the form `PVEAPIToken=terraform@pve!TOKENID=UUID`[^6] when making API requests, or refer to your API client’s documentation.

You can test the connection by entering the following command:

```Bash
curl https://PROXMOX_IP:8006/api2/json -k -H 'Authorization: PVEAPIToken=terraform@pve!TOKENID=UUID'
```

### Set up an Ubuntu cloud-init image

The Terraform-files used to create the Wazuh-environment require an Ubuntu cloud-init image to be present on the Proxmox-server to work. The script [add_template.ubuntu_22-04](/proxmox/add_template.ubuntu_22-04.sh) creates a this template from a cloud-init image. 

Copy the contents of the [add_template.ubuntu_22-04](/proxmox/add_template.ubuntu_22-04.sh)-script to the Proxmox-server,
either through an SSH-connection or the VE-webinterface (select the node, then select *Shell*).
Execute the following commands:

```Bash
nano add_template.ubuntu_22-04.sh
chmod +x add_template.ubuntu_22-04.sh
./add_template.ubuntu_22-04.sh
```

For more background on these commands, refer to Austin's tutorial[^7].


## Environment variables

To ensure that the right variables are used, create a `.env` file in the root directory of this repository.  
For instructions on the syntax of this directory, see [.env.example](/.env.example).  
Once the `.env`-file has been created, run the [readEnv](/readEnv.ps1) script to transform the .env-variables into environment variables usable by Terraform.

The following **variables** must be set in the */terraform/.env file*[^2]:
* TF_VAR_PM_API_TOKEN_ID (the ID of the API token)
* TF_VAR_PM_API_TOKEN_SECRET (the Secret of the API token)
* TF_VAR_PM_ADDR (the address of the Proxmox-server)
* TF_VAR_PM_PORT (the port of the Proxmox-server)
* TF_VAR_SSH_USER (the ssh-user to be created in the VMs made by Terraform)
* TF_VAR_SSH_KEY_PRIV[^4] (the private SSH-key to be placed in the VMs made by Terraform)
* TF_VAR_SSH_KEY_PUB (the public SSH-key to be placed in the VMs made by Terraform)
* TF_VAR_MONITORED_SERVERS (the amount of servers monitored by Wazuh)
* TF_VAR_MONITORED_WORKSTATIONS (the amount of workstations monitored by Wazuh)
* TF_VAR_MONITORED_NETWORK_DEVICES (the amount of network devices monitored by Wazuh)

*Depracated variables*
* ANSIBLE_VAULT_PASSWORD (the password to lock/unlock the Ansible Vault)
* ANSIBLE_VAULT_PASSWORD_FILE (the location of the password file, which is used to encrypt/decrypt yaml-files)
* SSH_KEY_NAME (the name of the SSH key used to connect to Proxmox)
* SSH_KEY_LOCATION (the location of the SSH key used to connect to Proxmox)
* VAULT_ADMIN_PASSWORD[^1] (the password for the admin user, used for logging in)
* VAULT_API_PASSWORD[^1] (the password for the wazuh user, used by the API)
* VAULT_API_WUI_PASSWORD[^1] (the password for the wazuh-wui user, used by the API)
* VAULT_VIRUSTOTAL_API_KEY[^3] (the VirusTotal API key, which will be encrypted in an Ansible Vault)

These variables can be used by terraform by executing the [readEnv script](/readEnv.ps1) (on a Windows computer):
```Bash
cd ./terraform/
../readEnv.ps1/
```

## Terraform

The infrastructure is declared in several Terraform-files in the [terraform](/terraform/) directory. 


Now, the infrastructure can be created and destroyed with the following commands:
```PowerShell
terraform init
terraform play
terraform apply
terraform apply -destroy
```

## Notes

[^7]: source: https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/
