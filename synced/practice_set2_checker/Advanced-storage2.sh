#!/bin/bash

# Helper functions to display success or failure messages
success() {
    echo -e "\e[32m$1 [SUCCESS]\e[0m"
}

failure() {
    echo -e "\e[31m$1 [FAILED]\e[0m"
}

# Check if volume group vg1 exists with size between 1200MB and 1360MB
vg_size=$(vgs --noheadings -o vg_size --units m vg1 | awk '{print $1}' | cut -d. -f1)
if [[ "$vg_size" -ge 1200 && "$vg_size" -le 1360 ]]; then
    success "Volume group vg1 exists with size between 1200MB and 1360MB."
else
    failure "Volume group vg1 does not exist or is not in the specified size range."
fi

# Check if logical volume lv-swap1 exists
if lvs /dev/vg1/lv-swap1 &>/dev/null; then
    success "Logical volume lv-swap1 exists."
else
    failure "Logical volume lv-swap1 does not exist."
fi

# Check if logical volume lv-swap1 has a size of 300M
lv_swap1_size=$(lvs --noheadings -o lv_size --units m /dev/vg1/lv-swap1 | awk '{print $1}' | cut -d. -f1)
if [[ "$lv_swap1_size" -eq 300 ]]; then
    success "Logical volume lv-swap1 has a size of 300M."
else
    failure "Logical volume lv-swap1 does not have a size of 300M."
fi

# Check if lv-swap1 is formatted with mkswap
if file -sL /dev/vg1/lv-swap1 | grep -q "Linux swap"; then
    success "Logical volume lv-swap1 is formatted with mkswap."
else
    failure "Logical volume lv-swap1 is not formatted with mkswap."
fi

# Check if lv-swap1 is persistently mounted as swap in fstab using UUID
lv_swap1_uuid=$(blkid -o value -s UUID /dev/vg1/lv-swap1)
if grep -q "UUID=$lv_swap1_uuid.*swap" /etc/fstab; then
    success "Logical volume lv-swap1 is persistently mounted as swap in fstab using UUID."
else
    failure "Logical volume lv-swap1 is not persistently mounted as swap in fstab using UUID."
fi

# Check if volume lv01 has a size of 500Mb
lv01_size=$(lvs --noheadings -o lv_size --units m /dev/vg1/lv01 | awk '{print $1}' | cut -d. -f1)
if [[ "$lv01_size" -eq 500 ]]; then
    success "Logical volume lv01 has a size of 500M."
else
    failure "Logical volume lv01 does not have a size of 500M."
fi

# Check if directory /mountlvm has a 500Mb filesystem
mountlvm_size=$(df --output=size -BM /mountlvm | tail -1 | sed 's/M//')
if [[ "$mountlvm_size" -eq 500 ]]; then
    success "Directory /mountlvm has a 500Mb filesystem."
else
    failure "Directory /mountlvm does not have a 500Mb filesystem."
fi
