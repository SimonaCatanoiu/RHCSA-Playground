
# Vagrant Box Creation Tutorial for RHEL 9 on VMware Fusion

This tutorial walks you through the steps of creating a Vagrant box for RHEL 9 ARM64 using VMware Fusion. You will create a virtual machine, install necessary tools, configure it, and package it for use with Vagrant.

## Steps

### 1. Download RHEL 9 ISO

Download the RHEL 9 ISO from the official source:

```yaml
https://developers.redhat.com/content-gateway/file/rhel/Red_Hat_Enterprise_Linux_9.5/rhel-9.5-aarch64-boot.iso
```

### 2. VMware Fusion Setup

Follow these steps to create the virtual machine in VMware Fusion:

1. Open **VMware Fusion**.
2. Go to **File** → **New**.
3. Select **Install from disk or image** and choose the downloaded RHEL 9 ISO.
4. Set the operating system type to **Linux** and version to **Red Hat Enterprise Linux 9**.
5. Select **Configuration** and click **Finish**.

After completing the above steps, the installation GUI will open. Follow these sub-steps:

- Connect to your **Red Hat account** during installation.
- Select **Server (no GUI)** as the installation type.
- Create a **vagrant** user without a password.

### 3. Configuring the Virtual Machine as Vagrant User

Once the VM is installed, follow these steps to set up SSH access for Vagrant.

1. Log in to the virtual machine as the **vagrant** user.
2. Create the `.ssh` directory and set permissions:

```bash
mkdir ~/.ssh
chmod 0700 ~/.ssh
cd ~/.ssh/
```

3. Download the Vagrant public key and set up `authorized_keys`:

```bash
wget https://raw.githubusercontent.com/hashicorp/vagrant/refs/heads/main/keys/vagrant.pub -O authorized_keys
chmod 0600 authorized_keys
```

### 4. Granting Sudo Access to Vagrant User

1. Open the sudoers file as root:

```bash
sudo visudo
```

2. Add the following lines to grant passwordless sudo access:

```bash
%wheel ALL=(ALL) NOPASSWD: ALL
vagrant ALL=(ALL) NOPASSWD: ALL
```

### 5. Installing Dependencies

Install the necessary dependencies on the virtual machine:

```bash
sudo yum install -y openssh wget
```

### 6. Installing VMware Tools

Install VMware Tools for better integration between the VM and host system:

1. Install required packages:

```bash
sudo yum install -y perl gcc make kernel-headers kernel-devel
```

2. Install VMware tools:

```bash
sudo dnf install -y open-vm-tools
sudo dnf install -y open-vm-tools-desktop
```

3. Enable and start VMware tools service:

```bash
sudo systemctl start vmtoolsd
sudo systemctl enable vmtoolsd
sudo reboot
```

### 7. Packaging the Virtual Machine

After completing the setup, package the virtual machine as a Vagrant box.

1. Create a directory to store the virtual machine files:

```bash
mkdir -p <your_path>/vmwarevmx
cd $HOME/Virtual\ Machines.localized/<vm_name>vmwarevm/
```

2. Copy the virtual machine files:

```bash
cp -r * <your_path>/vmwarevmx
```

3. Create a `metadata.json` file in the `vmwarevmx` directory with the following content:

```json
{
  "provider": "vmware_desktop"
}
```

4. Optimize the box file size by running these commands:

```bash
/Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -d <your_path>/vmwarevmx/Virtual\ Disk.vmdk
/Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -k <your_path>/vmwarevmx/Virtual\ Disk.vmdk
rm -rf <your_path>/vmwarevmx/*.log
rm -rf <your_path>/vmwarevmx/caches
rm -rf <your_path>/vmwarevmx/*.scoreboard
```

5. Compress the box:

```bash
cd <your_path>
tar cvzf rhel9-arm.vmware.box -C vmwarevmx .
```

6. Get the MD5 checksum of the `.box` file:

```bash
md5 rhel9-arm.vmware.box
```

Make sure to save this checksum value for use in the `metadata.json`.

7. Create a `metadata.json` file for Vagrant (this file should be in the same directory as the `.box` file):

```json
{
  "name": "<your_name>/rhel9-arm",
  "description": "RHEL 9 ARM version.",
  "versions": [
    {
      "version": "0.1.0",
      "providers": [
        {
          "name": "vmware_desktop",
          "url": "file://<path_to_box>/rhel9-arm.vmware.box",
          "checksum_type": "md5",
          "checksum": "<output_md5_command>"
        }
      ]
    }
  ]
}
```

8. Add the box to Vagrant:

```bash
vagrant box add <path_to_metadata>/metadata.json --provider vmware_desktop --force
```

### 8. Uploading the Box to HashiCorp Cloud (Optional)

If you want to upload your Vagrant box to HashiCorp's cloud registry, follow these steps:

1. Log in to the [HashiCorp Vagrant portal](https://portal.cloud.hashicorp.com/vagrant/discover).
2. Create a Vagrant registry and upload your box if you want it to be available for download from the cloud, rather than locally.

---

By following these steps, you will have successfully created and packaged a custom RHEL 9 ARM64 Vagrant box using VMware Fusion.
