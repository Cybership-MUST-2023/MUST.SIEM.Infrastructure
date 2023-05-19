#!/bin/bash
HOME_USER=must

echo "--- Setting timezone to Africa/Kampala ---"
sudo timedatectl set-timezone Africa/Kampala

# Ensure that the OpenSSH-server is on the system
echo "--- Install OpenSSH-server ---"
sudo apt-get install openssh-server
sudo systemctl start sshd

# Ensure that the authorized_keys file is present
echo "--- Set up SSH keys --- "
sudo chown $HOME_USER:$HOME_USER -R /home/$HOME_USER
cd ~
mkdir .ssh
chmod 700 .ssh/
touch .ssh/authorized_keys
chmod 644 .ssh/authorized_keys

# echo "--- Paste the public SSH key ---"
# sudo nano .ssh/authorized_keys

# Add the right SSH-configuration settings
echo "--- Add PubkeyAuthentication to the SSH configuration ---"
sudo sh -c 'echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config'
sudo sh -c 'echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config'

sudo systemctl restart sshd

echo "--- Ansible client setup complete ---"