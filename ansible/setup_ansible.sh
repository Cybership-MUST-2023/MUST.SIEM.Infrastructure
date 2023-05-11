#!/bin/bash
HOME_USER=must
ANSIBLE_KEY=MUST.Ansible

# hostname
echo "--- Setting timezone to Africa/Kampala ---"
sudo timedatectl set-timezone Africa/Kampala

# ansible installation
echo '--- Installing required dependencies ---'
sudo apt-get update -y
sudo apt-get install lsb-release software-properties-common -y

echo '--- Setup ansible repository ---'
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update -y
    
echo '--- Installing ansible ---'
sudo apt-get install ansible -y

echo '--- Installing ansible-lint ---'
sudo apt install yamllint ansible-lint -y


# set up SSH (new key)
chown $HOME_USER:$HOME_USER -R /home/$HOME_USER
cd /home/$HOME_USER

# echo "--- Write authentication key ---"
# nano ~/.ssh/ansible_key
# nano ~/.ssh/ansible_key.pub

echo "--- Setting correct permissions ---"
sudo chmod 700 .ssh
sudo chmod 600 ~/.ssh/$ANSIBLE_KEY
sudo ls -la .ssh/


# set up Wazuh-Ansible git
echo "--- downloading Wazuh-Ansible repo ---"
cd /etc/ansible/roles/
sudo git clone --branch 4.3 https://github.com/wazuh/wazuh-ansible.git
ls

# set up MUST playbooks
echo "--- downloading MUST_playbooks ---"
cd ./wazuh-ansible/
sudo git clone https://github.com/Cybership-Uganda-2023/MUST.SIEM.Ansible-playbooks

# set nano as preferred editor
echo "--- setting nano as preferred editor for Ansible"
sudo sh -c 'echo "export EDITOR=nano" >> /root/.bashrc'
sudo sh -c 'echo "export EDITOR=nano" >> /home/$HOME_USER/.bashrc'
sudo sh -c '. /root/.bashrc'
sudo sh -c '. /home/$HOME_USER/.bashrc'


echo "--- Ansible setup complete ---"