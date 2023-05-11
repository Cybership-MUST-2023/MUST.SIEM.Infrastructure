#!/bin/bash
# source: https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/

MEMORY=2048
CORES=2
SOCKETS=1
STORAGE=VMs

echo "--- Creating Ubuntu 22.04 LTS cloud-init template ---"

echo 
echo "Importing cloud image..."
rm jammy-server-cloudimg-amd64.img
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

echo
echo "Installing libguestfs-tools..."
apt update -y && sudo apt install libguestfs-tools -y

echo
echo "Installing qemu-agent in cloud image..."
virt-customize -a jammy-server-cloudimg-amd64.img --install qemu-guest-agent
echo "Emptying machine-id and creating symbolic link"
virt-customize -a jammy-server-cloudimg-amd64.img --truncate /etc/machine-id
virt-customize -a jammy-server-cloudimg-amd64.img --link /etc/machine-id:/var/lib/dbus/machine-id
echo "Removing SSH keys"
virt-customize -a jammy-server-cloudimg-amd64.img --command 'rm /etc/ssh/ssh_host_*'
echo "Cleaning the template"
virt-customize -a jammy-server-cloudimg-amd64.img --command 'apt clean'
virt-customize -a jammy-server-cloudimg-amd64.img --command 'apt autoremove'

echo
echo "Creating VM..."

qm create 9000 --name "ubuntu-2204-cloudinit-template" --memory $MEMORY --cores $CORES --cpu host --net0 virtio,bridge=vmbr0 --sockets $SOCKETS
qm importdisk 9000 jammy-server-cloudimg-amd64.img $STORAGE
qm set 9000 --scsihw virtio-scsi-pci --scsi0 $STORAGE:9000/vm-9000-disk-0.raw
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --ide2 $STORAGE:cloudinit
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --agent enabled=1

echo
echo "Converting VM to template..."
qm template 9000
rm jammy-server-cloudimg-amd64.img

echo
echo "--- Template created! ---"