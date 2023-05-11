#!/bin/bash
# source: https://dannyda.com

echo "--- Activated kill_vm.sh ---"
echo
echo "existing locks:"
ls /run/lock/qemu-server/ -l

while read -p 'Enter the VM ID here to delete corresponding lock, press Enter key to exit (e.g. 101): ' ID; do
echo 
if [[ "$ID" = "" ]] || [[ "$ID" = "q" ]] ;
then       
exit
elif [[ "$ID" -gt 0 ]] && [[ "$ID" -lt 1000000000 ]];
then
echo "unlocking $ID, removing lock-$ID.conf"
qm unlock $ID
rm -f /run/lock/qemu-server/lock-$ID.conf
qm unlock $ID
ls -l /run/lock/qemu-server
else
echo 'Input error, please enter correct VM ID.'
fi
done

echo
echo "--- Ended kill_vm.sh ---"