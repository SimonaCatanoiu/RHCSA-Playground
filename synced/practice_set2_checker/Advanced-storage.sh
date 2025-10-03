#!/bin/bash

# Function to print success in green
success() {
  echo -e "\e[32m$1\e[0m"
}

# Function to print failure in red
failure() {
  echo -e "\e[31m$1\e[0m"
}

# Check if vg1 exists and its size is between 600MB and 680MB
if vgs --noheadings -o vg_name,size | awk '{size=$2; gsub("[a-zA-Z]"," ", size); if ($1=="vg1" && size>=600 && size<=680) exit 0; exit 1}'; then
  success "Volume group vg1 exists with size between 600MB and 680MB."
else
  failure "Volume group vg1 does not exist or its size is not between 600MB and 680MB."
fi

# Check if logical volume lv01 of size between 280M and 320M exists
if lvs --noheadings -o lv_name,vg_name,lv_size | awk '{size=$3; gsub("[a-zA-Z]"," ", size); if ($1=="lv01" && $2=="vg1" && size>280 && size<320) exit 0; exit 1}'; then
  success "Logical volume lv01 of size between 280M and 320M exists exists in vg1."
else
  failure "Logical volume lv01 of size between 280M and 320M does not exist in vg1."
fi

# Check if an XFS filesystem exists on lv01
if df -Th | grep -q '/dev/mapper/vg1-lv01.*xfs'; then
  success "An XFS filesystem has been placed on logical volume lv01."
else
  failure "An XFS filesystem has not been placed on logical volume lv01."
fi

# Check if directory /mountlvm exists
if [ -d "/mountlvm" ]; then
  success "Directory /mountlvm exists."
else
  failure "Directory /mountlvm does not exist."
fi

# Check if logical volume lv01 is mounted on /mountlvm
if mount | grep -q '/dev/mapper/vg1-lv01 on /mountlvm type'; then
  success "Logical volume lv01 is mounted on /mountlvm."
else
  failure "Logical volume lv01 is not mounted on /mountlvm."
fi

# Find UUID of the logical volume lv01
lv_uuid=$(blkid -o value -s UUID /dev/mapper/vg1-lv01)

# Check if logical volume lv01 is persistently mounted on /mountlvm in fstab by UUID
if grep -q "UUID=$lv_uuid\s\+/mountlvm\s\+" /etc/fstab; then
  success "Logical volume lv01 is persistently mounted on /mountlvm in fstab by UUID."
else
  failure "Logical volume lv01 is not persistently mounted on /mountlvm in fstab by UUID."
fi

