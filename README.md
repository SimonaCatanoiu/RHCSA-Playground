
# 📦 Vagrant RHEL 9 Lab — RHCSA 124 (Apple Silicon / M1)

## 📖 About

This project creates a fully automated **RHEL 9 lab environment** using **Vagrant** for **macOS (Apple Silicon / M1)**, designed to replicate the **RHCSA 124 course lab**.  
It’s ideal for testing, practice, and learning in a controlled virtual infrastructure for Students and Linux enthusiasts working towards RHCSA certification.

---

## 📂 Project Structure

```
.
├── Vagrantfile
├── extras/
│   ├── initial-setup.sh
│   ├── bastion-setup.sh
│   ├── workstation-setup.sh
│   └── machines.yaml
└── synced/
└── docs/
```

---

## 📦 Vagrant Box

All virtual machines use **`simonaesy/rhel9-arm v0.1.0`**, a **custom Vagrant box specifically compiled for ARM64 (Apple Silicon / M1)**.

If you want to learn how to create your own custom VM box and publish it on the Vagrant Cloud registry, check out the documentation inside the [`docs/`](./docs) folder.

IP addresses and hostnames for the machines are defined in [`extras/machines.yaml`](./extras/machines.yaml).

---

## 🖥️ Virtual Machines

All virtual machines use **simonaesy/rhel9-arm v0.1.0**. This is an 

| VM          | Hostname                  | Private IP      | Public IP       | RAM  | CPU |
|--------------|----------------------------|----------------|----------------|------|-----|
| **Bastion**     | bastion.lab.example.com     | 172.25.250.254 | 172.25.250.222 | 1024 | 2   |
| **Workstation** | workstation.lab.example.com | 172.25.250.9   | -              | 2048 | 2   |
| **ServerA**     | servera.lab.example.com     | 172.25.250.10  | -              | 1024 | 2   |
| **ServerB**     | serverb.lab.example.com     | 172.25.250.11  | -              | 1024 | 2   |

---

## 🛠️ Provisioning Scripts

### `initial-setup.sh`
- Enables root login and password authentication via SSH
- Creates a `student` user with **wheel** group membership
- Sets passwords:  
  `root` → `redhat`  
  `student` → `student`
- Updates the system and installs basic utilities (vim, bash-completion)
- Enforces SELinux
- Enables and starts the firewall

### `bastion-setup.sh`
- Installs and starts DNS services (`bind` and `bind-utils`)

### `workstation-setup.sh`
- Creates a symbolic link `/home/student/synced` pointing to `/synced`
- Installs **Gnome GUI**
- Configures system to boot in graphical mode

---

## 📄 Configuration (extras/machines.yaml)

Defines VM names, hostnames, and network settings.

Example:
```yaml
bastion_hostname: 'bastion.lab.example.com'
bastion_ip: '172.25.250.254'
...
```

---

## 📂 Synced Folder

The local `synced/` directory is mounted to `/synced` inside the **workstation** VM for easy file sharing between macOS and the virtual environment.

🧪 **Usage Note**  
This folder is intended for scripts that will **check or automate practice test exercises**.  
To run a script, log in as `student` on the workstation and execute it like this:

```bash
/home/student/<practice_folder_set>/<script_name>.sh
```
---

## 📘 Study Materials

All **RHCSA practice exam prompts** and **official Red Hat guides** will be placed in the `/study-guide` folder inside the workstation VM.

You’ll find:
- Practice exam exercises
- Preparation labs
- Red Hat official PDFs (where applicable)

This will be your central hub for RHCSA exam preparation.

---

## 🚀 Getting Started

### 1. Install dependencies:
- [Vagrant](https://www.vagrantup.com/)
- [VMware Fusion](https://www.vmware.com/products/fusion.html)
- [Vagrant VMware plugin (Apple Silicon / ARM64 version)](https://developer.hashicorp.com/vagrant/install/vmware)
- Install required plugins:
  ```bash
  vagrant plugin install vagrant-vmware-desktop
  vagrant plugin install vagrant-vbguest
  vagrant plugin install vagrant-hostmanager
  ```

### 2. Clone the project:
```bash
git clone https://github.com/SimonaCatanoiu/RHCSA-Playground
cd RHCSA-Playground
```

### 3. Launch the environment:
```bash
vagrant up
```

### 4. SSH into any VM:
```bash
vagrant ssh bastion
```

---

## 🖥️ Working with the VMs (VMware Fusion Tips)


### 💡 Enabling Copy/Paste:

Inside VMware Fusion:
- Go to **Settings → Keyboard & Mouse**
- Map `Command + C` to `Ctrl + Shift + C`
- Map `Command + V` to `Ctrl + Shift + V`

### 💡 Making Vagrant-managed VMs visible in VMware Fusion:

1. In **VMware Fusion**, open **Virtual Machine Library**
2. Click **+ → Scan for Virtual Machines**
3. Add the path:  
   `<your_path_to_repo>/.vagrant/machines`

💡 **Note:**  
For the workstation VM, you will want to open the GUI in Fusion. There are 2 methods: 

## Method #1

The Workstation VM has an `v.gui = true` in the `Vagrantfile`. In order to open the GUI, you need to do the following after spinning up the VMs:

1. `vagrant suspend workstation`
2. `vagrant up workstation`

This will automatically open the VMWare Fusion GUI for you.

## Method #2 
The VMs will are available in Fusion **only when halted by Vagrant**. 

1. Run this command: `vagrant halt`, as Vagrant locks their control while running.
2. Manually open the VMs in VMWare Fusion.

---


## 🔒 Notes

- **SELinux** is set to **enforcing**
- **Firewall** is active on all VMs
- `student` user has **sudo** privileges via the `wheel` group

---

## 📌 Additional Info

- Tested on **macOS M1** with **VMware Fusion**
- RHEL 9 ARM boxes from: [simonaesy/rhel9-arm](https://app.vagrantup.com/simonaesy/boxes/rhel9-arm)
- Requires internet connection for box downloads and package installations
- If working on **Linux** instead, just change the `box` in the `Vagrantfile` and use `VMWare` instead of `VMWare Fusion` as the provider. 

---

## 📬 Contribution

For questions, suggestions, or improvements — feel free to open an issue or pull request.

---

## 🙌 Credits

Based on:
- [ive663’s RHCSA Vagrant Playground](https://github.com/ive663/RHCSA/tree/main/VagrantPlayground)
- [Creating a local Vagrant box for ARM64 RHEL9 with VMware Fusion](https://dc1888.medium.com/creating-a-local-vagrant-box-for-arm64-rhel9-with-vmware-fusion-968ba772f94c)

---
