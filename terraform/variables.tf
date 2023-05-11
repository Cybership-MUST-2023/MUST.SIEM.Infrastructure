# .env variables
# variable "PM_USER" {}
# variable "PM_PASS" {}
variable "PM_API_TOKEN_ID" {}
variable "PM_API_TOKEN_SECRET" {}
variable "PM_ADDR" {}
variable "PM_PORT" {}
variable "SSH_USER" {}
variable "SSH_KEY_PRIV" {}
variable "SSH_KEY_PUB" {}
variable "MONITORED_SERVERS" {}
variable "MONITORED_WORKSTATIONS" {}
variable "MONITORED_NETWORK_DEVICES" {}

# local variables
locals {

    # The volume of the disk is either the calculated value, or the default value, whichever is larger
    default_volume  = 8  # GB
    manager_volume  = var.MONITORED_SERVERS * 0.1 + var.MONITORED_WORKSTATIONS * 0.04 + var.MONITORED_NETWORK_DEVICES * 0.2
    indexer_volume  = var.MONITORED_SERVERS * 3.7 + var.MONITORED_WORKSTATIONS * 1.5 + var.MONITORED_NETWORK_DEVICES * 7.4
    stack_volume    = local.manager_volume + local.indexer_volume

    target_node     = "proxmox-03"
    
    instance_templates = {
        ubuntu_22_04 = "ubuntu-2204-cloudinit-template"
    }

    instance_defaults = {
        vmid        = 0
        os_type     = "cloud-init"
        hardware = {
            cpu     = "host"
            scsihw  = "virtio-scsi-pci"
            network = {
                model   = "virtio"
                bridge  = "vmbr0"
            }

            bootdisk = "scsi0"
            disk = {
                slot            = 0
                type            = "scsi"
                storage         = "local-lvm"
                storage_type    = "rbd"
                iothread        = 1
                ssd             = 1
                discard         = "on"
            }
        }
        ssh     = {
            user        = var.SSH_USER
            private_key = var.SSH_KEY_PRIV
        }

        network = {
            ssh_keys_allowed = var.SSH_KEY_PUB
            network_1 = {
                address = "172.26."
                subnet  = "/16"
            }

            gateway = "172.26.0.123"
        }
    }
}