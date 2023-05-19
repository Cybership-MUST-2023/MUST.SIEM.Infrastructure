# MUST SIEM solution with Wazuh on Proxmox

In this repository you will find a guide to install Wazuh on Proxmox through shell scripts and Ansible.

## Table of Contents

1. [Terraform](#terraform)
2. [Proxmox](#proxmox)
3. [Ansible](#ansible)
4. [Wazuh](#wazuh)
5. [Project status](#project-status)
6. [Notes](#notes)

## Terraform

The infrastructure is declared in several Terraform-files in the [terraform](/terraform/) directory. 
More information on these files can be found in [/terraform/README.md](/terraform/README.md).

These files are created using the [Telmate Proxmox provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
for Terraform.

Currently, the creation of virtual machines through these Terraform files is unstable and unrelaible.
It is not recommended to use these files without seriously revising them.
Instead, use the shell scripts detailed in [the Proxmox section](#proxmox).


## Proxmox

Once the Proxmox-server has been set up, the scripts in the [proxmox directory](/proxmox/) can be used to create the virtual machines required for the Ansible-Wazuh setup to run. 
Before this, a few extra files must be set up.

### SSH keys

Three SSH-keys must be created[^12]. 
One for basic SSH access into the virtual machines,
one for Ansible to connect to the clients and set their configuration,
and one used by the Ansible-playbooks to back up the Wazuh data.
These keys can be created with the following commands[^10]:

```Bash
cd /root/.ssh/
ssh-keygen -t ed25519 -C "Proxmox-key" -f "MUST.Proxmox"
ssh-keygen -t ed25519 -C "Ansible-key" -f "MUST.Ansible"
ssh-keygen -t ed25519 -C "Backup-key" -f "MUST.Backup"
```

Ensure that both the public and private keys are present in the Proxmox-server.
Then, a file must be created containing all public keys that will be authorized to access the Wazuh-servers.
This file can be created with the following commands (on the Proxmox-server):
```Bash
cd /root/.ssh/
touch MUST_keys_allowed
cat MUST.Proxmox.pub > MUST_keys_allowed
cat MUST.Ansible.pub >> MUST_keys_allowed
cat MUST.Backup.pub >> MUST_keys_allowed
```

### Setting up the Ansible scripts

The scripts in the [ansible directory](/ansible/) can be used to configure Ansible and its clients.
For more info on these scripts, see the [Ansible README file](/ansible/README.md).
The [Proxmox-shell-scripts](/proxmox/) can place these scripts on their relevant virtual machines,
but they must be present on the Proxmox-server first.

First, create a directory named `ansible-scripts`.
Then copy the contents of the Ansible scripts in this directory.

```Bash
mkdir ansible-scripts
nano ansible-scripts/setup_ansible.sh
nano ansible-scripts/setup_ansible_vault.sh
nano ansible-scripts/setup_client.sh
chmod +x ansible-scripts/setup_ansible.sh
chmod +x ansible-scripts/setup_ansible_vault.sh
chmod +x ansible-scripts/setup_client.sh
```

### Creating the VMs

In the [proxmox directory](/proxmox/), several shell scripts named `create_vm.<target>.sh` have been created.
These scripts must be copied to the Proxmox-server, given execute permissions and then executed.
All of these scripts start by declaring variables, which can be modified to tailer the virtual machine more to your needs.
These variables are based on the requirements of the different types of software used.
More information on these can be found in the [requirements folder](/requirements/).

To create the **Ansible** VM, execute the following commands, copying the contents of [create_vm.ansible.sh](/proxmox/create_vm.ansible.sh)[^11]:

```Bash
nano create_vm.ansible.sh
chmod +x create_vm.ansible.sh
./create_vm.ansible.sh
```

To create the **Wazuh-single** VM (containing the manager, indexer and dashboard), execute the following commands, copying the contents of [create_vm.wazuh-single.sh](/proxmox/create_vm.wazuh-single.sh)[^11]:

```Bash
nano create_vm.wazuh-single.sh
chmod +x create_vm.wazuh-single.sh
./create_vm.wazuh-single.sh
```

To create the **Wazuh-agent** VM, execute the following commands, copying the contents of [create_vm.wazuh-agent.sh](/proxmox/create_vm.wazuh-agent.sh)[^11]:

```Bash
nano create_vm.wazuh-agent.sh
chmod +x create_vm.wazuh-agent.sh
./create_vm.wazuh-agent.sh
```

To create the **Backup** VM (used to back up Wazuh data), execute the following commands, copying the contents of [create_vm.backup.sh](/proxmox/create_vm.backup.sh)[^11]:

```Bash
nano create_vm.backup.sh
chmod +x create_vm.backup.sh
./create_vm.backup.sh
```

## Ansible

For the Ansible installation and setup instructions, see the [ansible folder](/ansible/) and the [ansible README](/ansible/README.md).

## Wazuh

The Wazuh-configuration is done via Ansible, and can be found in https://github.com/WLAN-ITF-22-23/MUST.SIEM.Ansible-playbooks/. 

The following setup is created:

- A Wazuh all-in-one implementation, containing the indexer, dashboard and server
- A single Wazuh agent, a minimal Ubuntu 22.04 LTS server

Wazuh's functionality can be expanded through a large number of [settings and capabilities](https://documentation.wazuh.com/current/user-manual/capabilities/index.html). These capabilities are described in [the MUST_playbooks README file](https://github.com//WLAN-ITF-22-23//MUST.SIEM.Ansible-playbooks/blob/main/README.md).


## Project status

Currently, the Terraform-files do not work with Proxmox. The scripts in the [ansible directory](/ansible/) can be used to set up Ansible manually (see the [README file](/ansible/README.md)).

## Notes
*List the notes, problems and bugs that are not yet fixed in the current iteration of the project.*

[^1]: The password must have a length between 8 and 64 characters and contain at least one upper and lower case letter, a number and a symbol(.*+?-)

[^2]: For security reasons, this file is not added to the repository (it is excluded through [.gitignore](/.gitignore)). The user will have to add this file manually. To see an example of this file, see [.env.example](/terraform/.env.example)

[^3]: If you do not have a VirusTotal API key, set it to 'placeholder'

[^4]: You can generate a key pair on Windows by executing the following Powershell-command: `ssh-keygen -t ed25519 -C "MUST"`

[^5]: You can generate a token here: https://www.random.org/passwords/?num=1&len=24&format=plain&rnd=new

[^6]: The token ID is the ID you set when creating the token, also known as the Token name. The UUID is the Token Secret which was shown (once) after creating the token


[^8]: The name `VMs` is used in this example to represent the name of the Proxmox storage. You will need to modify this, based on your environment.

[^9]: The API Token ID needs to follow the following regex pattern: `(?^:[A-Za-z][A-Za-z0-9\.\-_]+)`

[^10]: Setting a passphrase is optional

[^11]: This process takes roughly 5 minutes to complete. Should the `qm resize` command returns a timeout error, manually executing it usually works as well (`qm resize $VM_ID scsi0 $DISK_SIZE`).

[^12]: Creating these on the Proxmox-server and copying them to your own host can lead to some weird permission denied errors. Creating them on your local host and copying them to the Proxmox-server seems to avoid this issue.