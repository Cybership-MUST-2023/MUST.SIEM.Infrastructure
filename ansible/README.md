# Ansible
*introduction*

Ansible is a great tool for automating the deployment of software and configuration.  
In this repository, you will find a guide on how to deploy a Wazuh environment via Ansible.

## Table of Contents

1. [Description](#description)
2. [On destroying and rebuilding the Proxmox servers](#on-destroying-and-rebuilding-the-proxmox-servers)
3. [Manual installation and setup of Ansible](#manual-installation-and-setup-of-ansible)
    1. [Ansible server](#ansible-server)
    2. [Ansible clients](#ansible-clients)
    3. [Test connection](#test-connection)
4. [Ansible vault](#ansible-vault)
4. [Ansible playbooks](#ansible-playbooks)
5. [Project status](#project-status)
6. [Known errors](#known-errors)

## On destroying and rebuilding the Proxmox servers
*which resources need to be adjusted to function in the newly created environment*

When restarting the servers, the IP addresses of the instances might change. 
Because of this, they also need to be changed in the following files in this repository:
- the [MUST_playbook inventory file](https://github.com/Cybership-Uganda-2023/MUST.SIEM.Ansible-playbooks/blob/main/inventory)
- the [MUST_playbook variables file](https://github.com/Cybership-Uganda-2023/MUST.SIEM.Ansible-playbooks/blob/main/vars/vars-development.yml)

## Manual installation and setup of Ansible

This guide follows the [official Wazuh documentation](https://documentation.wazuh.com/current/deployment-options/deploying-with-ansible/guide/install-ansible.html#remote-connection). You can do the installation following the guide, or use the scripts provided in this repository.

### Ansible server

To set up the configuration on the Ansible server, copy the contents of [setup_ansible.sh](./setup_ansible.sh)
into a script on the Ansible server[^2]. This script will prompt several nano-popups, to enter the SSH private and public key used to connect to the different Ansible clients.

```Bash
sudo nano setup_ansible.sh
sudo chmod +x setup_ansible.sh
sudo ./setup_ansible.sh
```

### Ansible clients

To ensure that the right SSH-infrastructure is present, copy the contents of [setup_client.sh](./setup_clients/setup_client.sh)
into a script on the Ansible clients. This script will prompt one nano-popup, to enter the SSH public key used by the Ansible server to connect to the different Ansible clients.[^3]

```Bash
sudo nano setup_client.sh
sudo chmod +x setup_client.sh
sudo ./setup_client.sh
```

### Test connection

From the ansible server, enter the following command to check if the configuration was applied successfully:

```Bash
sudo ansible Wazuh-agent -m ping
```

## Ansible vault

> Ansible Vault encrypts variables and files so you can protect sensitive content such as passwords or keys rather than leaving it visible as plaintext in playbooks or roles. To use Ansible Vault you need one or more passwords to encrypt and decrypt content. If you store your vault passwords in a third-party tool such as a secret manager, you need a script to access them. Use the passwords with the ansible-vault command-line tool to create and view encrypted variables, create encrypted files, encrypt existing files, or edit, re-key, or decrypt files. You can then place encrypted content under source control and share it more safely. ([Ansible vault documentation](https://docs.ansible.com/ansible/latest/vault_guide/vault.html))

Using the [setup_ansible_vault](/ansible/setup_ansible_vault.sh)-script, sensitive variables are encrypted. These variables are used by several playbook files, which can be seen in the [MUST playbook documentation](https://github.com/Cybership-Uganda-2023/MUST.SIEM.Ansible-playbooks/blob/main/README.md). To set up this vault, execute the following script, filling in the appropriate parameters:

```Bash
sudo nano setup_ansible_vault.sh
sudo chmod +x setup_ansible_vault.sh
sudo ./setup_ansible_vault.sh \
    ANSIBLE_PWD_FILE \
    ANSIBLE_PWD \
    VIRUSTOTAL_API_KEY \
    API_USER_PWD \
    API_USER_WUI_PWD \
    ADMIN_USER_PWD \
    SSH_KEY_LOCATION
```

The parameters are:
- ANSIBLE_PWD_FILE (The location of the file holding the password used to unlock the Ansible vault)
- ANSIBLE_PWD (The password, stored in the PWD_FILE, used to unlock the Ansible vault)
- VIRUSTOTAL_API_KEY (A [Virustotal API key](https://support.virustotal.com/hc/en-us/articles/115002100149-API))
- API_USER_PWD (The password for the Wazuh API user, normally called 'wazuh')
- API_USER_WUI_PWD (The password for the Wazuh-wui API user, normally called 'wazuh-wui)
- ADMIN_USER_PWD (The password for the Wazuh admin user, normally called 'admin')
- SSH_KEY_LOCATION (The location of the SSH key used by Ansible to connect to the clients, used by the backup and recovery playbooks)

Interesting sources:
- https://www.redhat.com/sysadmin/ansible-playbooks-secrets
- https://docs.ansible.com/ansible/latest/vault_guide/vault_encrypting_content.html
- https://devops4solutions.com/ansible-vault-password-in-ci-cd-pipeline/
- https://www.digitalocean.com/community/tutorials/how-to-use-vault-to-protect-sensitive-ansible-data

## Ansible playbooks
*installing Wazuh with Ansible*

This section largely follows the [official Wazuh documentation](https://documentation.wazuh.com/current/deployment-options/deploying-with-ansible/installation-guide.html).

The playbook files installed by [setup_ansible.sh](./setup_ansible.MUST.sh) can be found at https://github.com/Cybership-Uganda-2023/MUST.SIEM.Ansible-playbooks. For more information on how to set up and install these files, consult the [README file on the MUST.SIEM.Ansible-playbooks repository](https://github.com/Cybership-Uganda-2023/MUST.SIEM.Ansible-playbooks/blob/main/README.md).

The Wazuh-dashboard can now be reached internally by using the dashboard instance's private IP, at `https://<private IP>`, and exteranally by using the dashboard instance's public DNS addressn at `https://<public DNS>`.[^1]
 
## Notes
*List the notes, problems and bugs that are not yet fixed in the current iteration of the project.*

[^1]: If you recieve the following alert: `ERROR: No template found for the selected index-pattern title [wazuh-alerts-*]`, try entering the following command on the **Wazuh-manager**: `curl --silent https://raw.githubusercontent.com/wazuh/wazuh/${wazuh_major}/extensions/elasticsearch/7.x/wazuh-template.json | curl -X PUT 'https://elasticsearch_IP:9200/_template/wazuh' -H 'Content-Type: application/json' -d @- -uadmin:admin -k --silent`. (source: https://groups.google.com/g/wazuh/c/aSAIqc2_1ig)

[^2]: If using the [proxmox scripts](/proxmox/), these files are already present on the VMs

[^3]: The setup scripts should modify the `/home/must` directory to transfer ownership to the must-user. If this does not work, execute the following command on each Ansible-client: `sudo chown must:must /home/must -R`