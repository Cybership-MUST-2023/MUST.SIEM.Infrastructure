/* Uses Cloud-Init options from Proxmox 5.2 */
resource "proxmox_vm_qemu" "MUST_Ansible" {
    vmid        = 200  # + count.index
    count       = 1
    name        = "MUST-Ansible" #-${count.index+1}"
    desc        = "MUST Ansible VM"

    target_node = local.target_node

    clone       = local.instance_templates.ubuntu_22_04
    full_clone  = true

    # The destination resource pool for the new VM
    # pool    = local.resource_pool

    # agent       = 1
    os_type     = local.instance_defaults.os_type


    cores       = 4
    sockets     = 1
    memory      = 4096 # MB
    cpu         = local.instance_defaults.hardware.cpu
    scsihw      = local.instance_defaults.hardware.scsihw
    bootdisk    = local.instance_defaults.hardware.bootdisk
    disk    {
        # slot            = local.instance_defaults.hardware.disk.slot
        size            = "32G"
        type            = local.instance_defaults.hardware.disk.type
        storage         = local.instance_defaults.hardware.disk.storage
        iothread        = local.instance_defaults.hardware.disk.iothread
        # ssd             = local.instance_defaults.hardware.disk.ssd
        # discard         = local.instance_defaults.hardware.disk.discard
    }

    network {
        model           = local.instance_defaults.hardware.network.model
        bridge          = local.instance_defaults.hardware.network.bridge
    }

    lifecycle {
        ignore_changes = [
            network,
        ]
    }

    # Cloud-init settings
    # ssh_user        = local.instance_defaults.ssh.user
    # ssh_private_key = local.instance_defaults.ssh.private_key
    # sshkeys         = local.instance_defaults.network.ssh_keys_allowed

    ipconfig0   = "ip=${local.instance_defaults.network.network_1.address}0.200${local.instance_defaults.network.network_1.subnet},gw=${local.instance_defaults.network.gateway}"

    

    # provisioner "remote-exec" {
    #     inline = [
    #         "ip a"
    #     ]
    # }
}

# Modify path for templatefile and use the recommended extention of .tftpl for syntax hylighting in code editors.
# resource "local_file" "cloud_init_user_data_file" {
#     count    = var.vm_count
#     content  = templatefile("${var.working_directory}/cloud-inits/cloud-init.cloud_config.tftpl", { ssh_key = var.ssh_public_key, hostname = var.name })
#     filename = "${path.module}/files/user_data_${count.index}.cfg"
# }

# resource "null_resource" "cloud_init_config_files" {
#     count = var.vm_count
#     connection {
#         type     = "ssh"
#         user     = "${var.pve_user}"
#         password = "${var.pve_password}"
#         host     = "${var.pve_host}"
#     }

#     provisioner "file" {
#         source      = local_file.cloud_init_user_data_file[count.index].filename
#         destination = "/var/lib/vz/snippets/user_data_vm-${count.index}.yml"
#     }
# }
