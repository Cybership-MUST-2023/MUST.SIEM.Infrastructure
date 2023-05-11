#!/bin/bash

#-----------------#
#    Variables    #
#-----------------#
IMAGE=jammy-server-cloudimg-amd64.img
IMAGE_URL=https://cloud-images.ubuntu.com/jammy/current/$IMAGE

# Proxmox
VM_ID=211
COUNT=1
NAME=must-wazuh-agent
DESC="MUST Wazuh agent VM"

NODE=proxmox-03
STORAGE=VMs

# VM
OS_TYPE=cloud-init

# Hardware
MEMORY=2048  # MB
CORES=1
SOCKETS=1

DISK_SLOT=0
DISK_SIZE="8G"
DISK_TYPE=scsi
DISK_STORAGE=VMs
DISK_IOTHREAD=1

# Network
IP_ADDR="172.26.2.11"
IP_SUBNET="/16"
IP_GATEWAY="172.26.0.123"

# Cloud init
SSH_USER=must
SSH_PRIV_KEYS=( /root/.ssh/MUST.Backup )   # Private SSH keys to be placed on the Ansible VM (stored on Proxmox server)
SSH_KEYS_ALLOWED=/root/.ssh/MUST_keys_allowed # SSH keys allowed to connect to the Ansible server

ANSIBLE_SCRIPTS_DIR=/root/ansible-scripts
ANSIBLE_SCRIPTS=( setup_client.sh )

#-----------------#
#     Commands    #
#-----------------#

echo "--- Creating Ubuntu 22.04 LTS cloud-init template ---"

echo 
echo "Importing cloud image..."
rm $IMAGE
wget $IMAGE_URL

echo
echo "Installing libguestfs-tools..."
apt update -y && sudo apt install libguestfs-tools -y

echo
echo "Installing qemu-agent in cloud image..."
virt-customize -a $IMAGE --install qemu-guest-agent
echo "Emptying machine-id and creating symbolic link"
virt-customize -a $IMAGE --truncate /etc/machine-id
virt-customize -a $IMAGE --link /etc/machine-id:/var/lib/dbus/machine-id

echo "Placing Ansible private key"
virt-customize -a $IMAGE --mkdir /root/
virt-customize -a $IMAGE --mkdir /root/.ssh/
for private_key in "${SSH_PRIV_KEYS[@]}"
do
   virt-customize -a $IMAGE --copy-in $private_key:/root/.ssh
done

echo "Placing Ansible setup scripts"
virt-customize -a $IMAGE --mkdir /home
virt-customize -a $IMAGE --mkdir /home/$SSH_USER/
virt-customize -a $IMAGE --mkdir /home/$SSH_USER/scripts/
for script in "${ANSIBLE_SCRIPTS[@]}"
do
   virt-customize -a $IMAGE --copy-in $ANSIBLE_SCRIPTS_DIR/$script:/home/$SSH_USER/scripts/
done

echo
echo "--- Creating Ansible VM from image ---"   

qm create $VM_ID --name $NAME --memory $MEMORY --cores $CORES --cpu host --net0 virtio,bridge=vmbr0 --sockets $SOCKETS
# Volume size source: https://forum.proxmox.com/threads/create-a-new-vm-and-set-the-disk-size-via-cli.102336/
qm importdisk $VM_ID $IMAGE $STORAGE
qm set $VM_ID --description "$DESC"
qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 $STORAGE:$VM_ID/vm-$VM_ID-disk-0.raw
qm set $VM_ID --boot c --bootdisk scsi0
qm set $VM_ID --ide2 $STORAGE:cloudinit
qm set $VM_ID --serial0 socket --vga serial0

echo "Setting cloud-init configuration"
qm set $VM_ID --agent enabled=1
qm set $VM_ID --ciuser $SSH_USER
qm set $VM_ID --ipconfig0 ip=$IP_ADDR$IP_SUBNET,gw=$IP_GATEWAY 
qm set $VM_ID --sshkeys $SSH_KEYS_ALLOWED

echo "Resizing disk... (if this takes forever, something has gone wrong. CTRL + C recommended. Use the command 'qm resize $VM_ID scsi0 $DISK_SIZE' manually)"
qm resize $VM_ID scsi0 $DISK_SIZE

echo "--- VM $VM_ID created ---"

echo
echo "--- Cleaning up... ---"

rm $IMAGE

echo "--- Script complete ---"