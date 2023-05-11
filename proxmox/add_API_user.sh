#!/bin/bash
# pveum docs: https://pve.proxmox.com/pve-docs/pveum.1.html

echo
read -p 'Enter the password for user terraform-prov: ' PWD
echo
read -p 'Enter the API Token ID: ' TOKENID

echo "--- Adding the TerraformProv role ---"
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"

echo "--- Adding the terraform-prov@pve user ---"
pveum user add terraform-prov@pve --password $PWD --comment "Terraform API user"

echo "--- Adding the TerraformProv role to the terraform-prov@pve user ---"
pveum acl modify / -user terraform-prov@pve -role TerraformProv

echo "--- Adding API key for user terraform-prov@pve ---"
pveum user token add terraform-prov@pve $TOKENID --comment "Terraform API Token" --privsep 0

echo "--- Script ended. Make sure to save the API Token Secret shown above! ---"