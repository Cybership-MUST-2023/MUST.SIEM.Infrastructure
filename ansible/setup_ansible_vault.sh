#!/bin/bash
# Reading input variables
ANSIBLE_PWD_FILE=$1
ANSIBLE_PWD=$2
VIRUSTOTAL_API_KEY=$3
API_USER_PWD=$4
API_USER_WUI_PWD=$5
ADMIN_USER_PWD=$6
SSH_KEY_LOCATION=$7

USER='must'
DIR="/etc/ansible/roles/wazuh-ansible/MUST.SIEM.Ansible-playbooks/vars"
SECRETS_FILE="$DIR/secrets-development.yml"

# create a password file for Ansible
echo "--- creating the Ansible password file ---"
sudo touch $ANSIBLE_PWD_FILE
sudo sh -c "echo '$ANSIBLE_PWD' > $ANSIBLE_PWD_FILE"

# set nano as preferred editor
echo "--- setting nano as preferred editor for Ansible"
sudo sh -c 'echo "export EDITOR=nano" >> /root/.bashrc'
sudo sh -c 'echo "export EDITOR=nano" >> /home/$USER/.bashrc'
sudo /bin/bash -c '. /root/.bashrc'
sudo /bin/bash -c '. /home/$USER/.bashrc'

# create secret variable file
echo "--- creating and encrypting secrets file ---"
cd /etc/ansible/roles/wazuh-ansible/MUST.SIEM.Ansible-playbooks
sudo rm $SECRETS_FILE
sudo touch $SECRETS_FILE
### Add variables before encryption
sudo /bin/bash -c "echo 'virustotal_api_key: $VIRUSTOTAL_API_KEY' > $SECRETS_FILE"
sudo /bin/bash -c "echo 'api_password: $API_USER_PWD' >> $SECRETS_FILE"
sudo /bin/bash -c "echo 'api_wui_password: $API_USER_WUI_PWD' >> $SECRETS_FILE"
sudo /bin/bash -c "echo 'admin_password: $ADMIN_USER_PWD' >> $SECRETS_FILE"
sudo /bin/bash -c "echo 'ssh_key_location: $SSH_KEY_LOCATION' >> $SECRETS_FILE"

###
sudo ansible-vault encrypt --vault-password-file $ANSIBLE_PWD_FILE $SECRETS_FILE

echo "--- Ansible vault setup complete ---"