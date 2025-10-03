# Exam Practice Notes

## Exercise 1 - Configure IP, netmask, gateway, DNS, and hostname on the machine

**Option a**  
Using `nmtui` → go through all the menus to configure and activate the connection. ( don't forget to activate the connection )

**Option b**  
```bash
sudo hostnamectl set-hostname servera    # set hostname
sudo nmcli device status                 # check interface or use ip a
sudo nmcli con mod ens160 ipv4.method manual ipv4.addresses 192.168.1.100/24 ipv4.gateway 192.168.1.1 ipv4.dns "8.8.8.8"
sudo nmcli con up ens160
```

**Verification:**
```bash
route -n
cat /etc/resolv.conf
hostname
ping servera
```

**Important**: Make sure `autoconnect yes` is enabled and the `connection.autoconnect-priority` is higher than any other existing connection.  
```bash
nmcli connection modify "connection name" connection.autoconnect-priority <value>
```

## Exercise 2 - Configure a yum repository on the VM for packages

**Option a**  
Edit `/etc/yum.repos.d/myrepo.repo`:
```bash
[base]
name=base
baseurl=my_url
gpgcheck=0
enabled=1
```

**Option b**  
```bash
sudo yum install yum-utils
sudo yum-config-manager --add-repo my_url
```
Then add `gpgcheck=0` in `/etc/yum.repos.d/myrepo.repo`.

**Verification:**
```bash
yum repolist
yum search httpd
```

**Exam note**: You may be asked to add **BaseOS** and **AppStream** repo URLs and register with username and password:
```bash
yum subscription-manager register --username user --password passwd
```

## Exercise 3 - httpd service not working on port 82

Check logs:
```bash
journalctl -xe
systemctl status httpd
```

If SELinux is the issue:
```bash
semanage port -l | grep 80
sudo semanage port -a -t http_port_t -p tcp 82
sudo systemctl restart httpd
```

If it still doesn’t work, check firewall:
```bash
firewall-cmd --add-port=82/tcp --permanent
firewall-cmd --reload
```


## Exercise 4 - Configure users and permissions

- Create sysadm group  
  ```bash
  groupadd sysadm
  ```

- User harry in sysadm as secondary group  
  ```bash
  useradd -aG sysadm harry
  ```

- User natasha in sysadm as secondary group  
  ```bash
  useradd -aG sysadm natasha
  ```

- User sarah without interactive shell and not in sysadm  
  ```bash
  useradd -s /sbin/nologin sarah
  ```

- All users should have password “password”  
  ```bash
  passwd <user>
  ```

- sysadm group members can add new users  
  ```bash
  which useradd
  visudo
  # Add line:
  %sysadm ALL=(ALL:ALL) /usr/sbin/useradd
  ```

- harry can set passwords for other users without sudo password  
  ```bash
  which passwd
  visudo
  # Add line:
  harry ALL=(ALL:ALL) NOPASSWD: /usr/sbin/passwd
  ```

## Exercise 5 - Create shared directory for sysadm

- Create directory:
  ```bash
  mkdir -p /shared/sysadm
  ```

- Set group ownership to sysadm:
  ```bash
  chgrp sysadm /shared/sysadm
  ```

- Allow only sysadm members access:
  ```bash
  chmod 770 /shared/sysadm
  ```

- Ensure files inherit sysadm group (SGID):
  ```bash
  chmod 2770 /shared/sysadm
  ```

## Exercise 6 - Set up a cronjob for Natasha

Configure a cronjob for user **natasha** to run every minute of every day and log the message *"Ex200 Testing"*.

```bash
which logger
crontab -e -u natasha
* * * * * /usr/bin/local/logger "Ex200 Testing"
systemctl restart crond
```


## Exercise 7 - Configure autofs for netuser's home directory

- netuser’s home directory is exported via NFS from `classroom.example.com (172.25.254.254)`  
- The export directory is `/netdir` on the local machine (append username to path).  
- Remote directory: `classroom.example.com:/home/guests/netuser`  
- Must be automounted via autofs  
- Must be writable by other users  
- Password for user netuser: `parola`  

Steps:
```bash
yum install nfs-utils
yum install autofs

vim /etc/auto.master
# Add line:
/netdir /etc/auto.misc

vim /etc/auto.misc
# Add line:
netuser -fstype=nfs,rw,sync classroom.example.com:/home/guests/netuser

systemctl restart autofs
systemctl enable autofs
```

**Test:**
```bash
ssh netuser@localhost
cd /netdir/netuser
ls
```


## Exercise 8 - Create tar archive

Create a `.bzip2` tar archive of `/etc/` named **myetcbackup.tar**.

```bash
tar -cfj myetcbackup.tar.bz2 /etc/
```


## Exercise 9 - Copy and set permissions

Copy `/etc/fstab` to `/var/tmp` and configure permissions:
- owner root, group root
- readable by all, no execute
- natasha can read/write
- harry no access


```bash
cp /etc/fstab /var/tmp
chown root:root /var/tmp/fstab          
chmod 644 /var/tmp/fstab                
setfacl -m u:natasha:rw- /var/tmp/fstab 
setfacl -m u:harry:--- /var/tmp/fstab  
```


## Exercise 10 - Synchronize time with classroom.example.com

```bash
yum install chrony
vim /etc/chrony.conf
# Add line:
server classroom.example.com iburst

systemctl restart chronyd
```


## Exercise 11 - Find all files owned by natasha

Find all files owned by natasha and copy them to `/root/natashafiles`:

```bash
sudo find /home -user natasha -exec cp -rf '{}' /root/natashafiles \;
```


## Exercise 12 - Find specific strings

Find all strings `"ich"` in `/usr/share/dict/words` and copy them to `/root/lines`:

```bash
grep "ich" /usr/share/dict/words > /root/lines
```


## Exercise 13 - Create user

Create user `unilao` with UID `2334` and password `ablerate`:

```bash
useradd -u 2334 unilao
passwd unilao
```


## Exercise 14 - Change root password on ServerB

Steps:

1. `sudo systemctl reboot`  
2. At GRUB, press ↓ and then `e`  
3. Change `ro` to `rw` and append `init=/bin/bash` at the end of the kernel line  
4. Press `CTRL+X`  
5. In the shell:  
   ```bash
   passwd root
   touch /.autorelabel
   exec /sbin/init
   ```


## Exercise 15 - Configure repos

Configure BaseOS and AppStream repos (same as Exercise 2).

## Exercise 16 - Create LVM wshare

- VG name: **wgroup**  
- LV name: **wshare**  
- PE size: 8MB  
- LV size: 50 extents → ~400MB (8*50) -> set to 500MB to be sure  
- Format ext4 and mount at `/mnt/wshare`  
- Auto-mount after reboot  

Steps:
```bash
lsblk
fdisk /dev/vdb
    n
    p
    1
    last selector: +500M
    t
    Hex code pt LVM: 8e
    w

partprobe /dev/vdb
pvcreate /dev/vdb1
vgcreate -s 8M wgroup /dev/vdb1
lvcreate -l 50 -n wshare wgroup

mkfs.ext4 /dev/wgroup/wshare
mkdir /mnt/wshare

vim /etc/fstab
/dev/wgroup/wshare /mnt/wshare ext4 defaults 0 0

mount -a
df -h
```

**Extending LV and resizing in the same command:**
```bash
lvextend -r -L 500M /dev/wgroup/wshare
```

## Exercise 17 - Create swap partition

Create a swap partition of 400M and make it permanent:

```bash
fdisk /dev/vdb
# new partition +400M, type 82

partprobe /dev/vdb
mkswap /dev/vdb2
swapon /dev/vdb2

blkid # to get the UUID
# Add UUID to /etc/fstab:
UUID=<UUID> swap swap defaults 0 0

mount -a
```

## Exercise 18 - Resize LVM to ~300MB

Check current LVs:
```bash
lvs
```

To resize the logical volume:
```bash
umount /mnt/wshare
lvresize -r -L 300M /dev/wgroup/wshare   # unmounting depends if you extend or shrink
lvresize -r -L -100M /dev/wgroup/wshare  # subtract size -> need unmounting
lvresize -r -L +100M /dev/wgroup/wshare  # add size -> doesn't need unmounting
mount -a
df -h
```


## Exercise 19 - Configure tuned recommended profile

```bash
yum install tuned
systemctl enable --now tuned

tuned-adm list
tuned-adm recommend
tuned-adm profile <profile_name>

# Verify
tuned-adm active
```


## Exercise 20 - Create a login message application

Create an application called rhcsa that prints a message when you log in as the user ablerate.

Create script `/usr/local/bin/rhcsa`:
```bash
#!/bin/bash
echo "Welcome user!"
```

```bash
chmod 755 /usr/local/bin/rhcsa
```

Add this line in `/home/ablerate/.bashrc`:
```bash
/usr/local/bin/rhcsa
```

Verify login:
```bash
ssh ablerate@serverb
```


## Exercise 21 - Build container image

Download a Containerfile from a link and build an image based on the file. → It is recommended to do this using the user who will also run the container as a service.
```bash
ssh user1@localhost #don't use su
wget <URL>
podman build -t myimage:v1 .
```


## Exercise 22 - Configure container autostart

Configure a container to start automatically.
- The image should be the previously built one.
- The container should be named mycontainer.
- It should automatically mount the directory /opt/file on the host to /opt/incoming in the container, and /opt/processed on the host to /opt/outgoing in the container.
- It must run as a systemd service that runs only for the user user1.
- The service should be named mycontainer and start automatically at boot or after a manual intervention."

1. Install Podman:
```bash
dnf install podman container-tools -y
```

2. Run container:
```bash
ssh user1@localhost #don't use su
podman run -d --name mycontainer \
  -v /opt/file:/opt/incoming:Z \
  -v /opt/processed:/opt/outgoing:Z \
  localhost/myimage:v1
```

3. Enable linger for user1 so that he can run containers in systemd:
```bash
loginctl show-user user1 #to see what linger the user has
loginctl enable-linger user1 
```

4. Generate systemd user service:
```bash
mkdir -p ~/.config/systemd/user
cd ~/.config/systemd/user
podman generate systemd --name mycontainer_service_name --files --new 
```

5. Enable the service:
```bash
systemctl --user daemon-reload
systemctl --user enable --now mycontainer.service
```


## Exercise 23 - Create admins directory
Create a catalog under /home named admins. Its respective group is requested to be the admin group. The group users could read and write, while other users are not allowed to access it. The files created by users from the same group should also be the admin group.


Create `/home/admins` with group `admin`:
```bash
groupadd admin
mkdir /home/admins
chgrp admin /home/admins
chmod 2770 /home/admins   # SGID, group members rwx, others no access
```


## Exercise 24 - Configure autofs for public/private NFS mounts
Auto mount the following NFS Shares on servera.lab.example.com at the /automount directory: nfs.lab.example.com:/public and nfs.lab.example.com:/private
- Public share has read only to all
- Private read write to all
- Shares get unmounted if not in use for 30 seconds
```bash
dnf install autofs* -y
dnf install nfs* -y

mkdir -p /automount/public
mkdir -p /automount/private
```

Edit `/etc/auto.master`:
```bash
/automount /etc/auto.automount --timeout=30
```

Edit `/etc/auto.automount`:
```bash
public  -ro,sync nfs.lab.example.com:/public
private -rw,sync nfs.lab.example.com:/private
```

Enable autofs:
```bash
systemctl enable --now autofs
```

Verify:
```bash
showmount -e nfs.lab.example.com
```


## Exercise 25 - Cronjob for harry, deny natasha

Create a cronjob for harry that prints a message at 12:30. Also, prevent the user natasha from using crontab.
```bash
crontab -e -u harry
30 12 * * * /bin/echo "hello"
```

Deny natasha:
```bash
echo "natasha" >> /etc/cron.deny
```


## Exercise 26 - Configure NTP client

Configure the system to be a client of the NTP server ntp.lab.example.com.
```bash
dnf install chrony* -y
vim /etc/chrony.conf
# Add:
server ntp.lab.example.com iburst

systemctl restart chronyd.service

# Verify
chronyc sources
```


## Exercise 27 - Find files >4MB
Find all files larger than 4MB in /etc and copy them to /find/largefiles.

```bash
mkdir -p /find/largefiles
find /etc -type f -size +4M -exec cp -v {} /find/largefiles/ \;
```

## Exercise 28 - Set umask for natasha

New files created by natasha should have `-r--` permissions.

New directories created by natasha should have `dr-x` permissions.

Set umask for natasha:
```bash
su - natasha
vim .bash_profile
# Add:
umask 0277
```


## Exercise 29 - Set password expiration for new users

All new users should have passwords expire after 20 days. Modify `/etc/login.defs`:
```bash
# Search for PASS_MAX_DAYS and set:
PASS_MAX_DAYS 20
```


## Exercise 30 - Allow admin group to use sudo without password

Add to `/etc/sudoers`:
```bash
%admin ALL=ALL NOPASSWD: ALL
```


## Exercise 31 - Resize logical volume

Resize previously created logical volume `database` by +100 extents:
```bash
lvs
lvresize -l +100 -r /dev/datastore/database
lvs
```


## Exercise 32 - Add registry for Podman

**Option 1:**
```bash
vim /etc/containers/registries.conf
# Add registry under unqualified-search-registries
```

**Option 2:**
```bash
mkdir -p /home/student/.config/containers
vim /home/student/.config/containers/registries.conf
# Add required registry
```

If login is needed:
```bash
podman login <registry> --tls-verify=false  # enter username and password
podman search httpd
podman pull <search_result>
```

Run container with port mapping:
```bash
podman run -p [HOST_PORT]:[CONTAINER_PORT] IMAGE
```


## Exercise 33 - Cronjob for natasha

Configure a cron job every 2 minutes as user natasha:
```bash
sudo crontab -e -u natasha
*/2 * * * * /usr/bin/logger "EX200 in progress"
```


## Exercise 34 - User account validity and permissions

Set user1 account validity to 1 month:
```bash
sudo chage -E $(date -d "+30 days" +"%Y-%m-%d") user1
```

Set user2 password constraints:
```bash
sudo chage -m 2 -M 60 -W 5 user2
```

Allow user1 full access to user2 home directory:
```bash
sudo setfacl -m u:user1:rwx /home/user2
```


## Exercise 35 - Create logical volume for swap

Create a 300MB logical volume `lv_swap2` and add it to swap:
```bash
sudo vgs
sudo lvcreate -L 300M -n lv_swap2 vg0
sudo mkswap /dev/vg0/lv_swap2
sudo swapon /dev/vg0/lv_swap2
swapon -s
```

Add it permanently to `/etc/fstab`:
```bash
sudo nano /etc/fstab
# Add:
/dev/vg0/lv_swap2   swap   swap   defaults   0 0
```

## Exercise 36 - Search for text and copy to file

Search for 'digitribe' in `/usr/share/dict/words` and copy to `/root/mysearch` without blank lines, preserving order:
```bash
grep 'digitribe' /usr/share/dict/words | sed '/^$/d' > /root/mysearch
```

## Exercise 37 - Locate files by user and sticky bit

Locate all files owned by `user1` and copy to `/root/user1_files`:
```bash
sudo find / -user user1 -type f -exec cp --parents {} /root/user1_files/ \; 2>/dev/null
```

Locate all files with sticky bit and copy to `/root/sticky`:
```bash
sudo find / -type f -perm -1000 -exec cp --parents {} /root/sticky/ \; 2>/dev/null
```


## Exercise 38 - Download and mount ISO permanently

Download iso from tp://ipa.mydomain.com/pub/boot.iso and mount boot.iso permanently to /MyISO.
```bash
wget ftp://ipa.mydomain.com/pub/boot.iso -O /root/boot.iso
sudo mkdir -p /MyISO
sudo mount -o loop /root/boot.iso /MyISO
sudo nano /etc/fstab
# Add line:
/root/boot.iso  /MyISO  iso9660  loop  0  0
sudo umount /MyISO
sudo mount -a
```

## Exercise 39 - Create container image

Create a container image from the provided link.
- create a container image from "http://utility.example.com/container/Containerfile" name it as'monitor'with user athena
- login to 'registry.lab.example.com' through "admin" and "redhat321" ->find out credentials from Instructions page
```bash
# Login as athena
id athena
ssh athena@localhost
podman login registry.lab.example.com
# Enter username: admin, password: redhat321
wget http://utility.example.com/container/Containerfile
podman build -t monitor .
podman images localhost/monitor
exit
```

## Exercise 40 - Create rootless container with volume mapping

Create rootless container and do volume mapping which they asked you in the question and run container as a service from normal user account, the service must be enable so it could start automatically after reboot
- Create a container named as 'ascii2pdf' using the previously created container image from previous question 'monitor'
- Map the opt/processed' to container /pt/outgoing 
- Map the /opt/files' to container /opt/incoming' 
- Create systemd service as container-ascii2pdf.service

```bash
# Prepare directories
mkdir /opt/files
chown -R athena:athena /opt/files
mkdir /opt/processed
chown -R athena:athena /opt/processed

# Run container
ssh athena@localhost
podman run -d --name ascii2pdf \
  -v /opt/files:/opt/incoming:Z \
  -v /opt/processed:/opt/outgoing:Z \
  localhost/monitor

# Configure systemd service
mkdir -p /home/athena/.config/systemd/user/
cd /home/athena/.config/systemd/user/
podman generate systemd --name ascii2pdf --files --new
systemctl --user daemon-reload
systemctl --user enable container-ascii2pdf.service
systemctl --user start container-ascii2pdf.service
loginctl enable-linger athena
systemctl --user restart container-ascii2pdf.service
podman ps
```

## Exercise 41 - Script to find files by size

Create a script to store search results of files in `/us/share` larger than 30k and smaller than 50k:
```bash
vim test.sh
#!/bin/bash
find /us/share/ -uid 0 -size +30k -size -50k >/mnt/freespace/search.txt
:wq
chmod +x test.sh
```

## Exercise 42 - Change default password policy

Change the default password policy so that newly created users have passwords that must be changed every 60 days
```bash
vim /etc/login.defs
# Set maximum password age for new users
PASS_MAX_DAYS 60
```

## Exercise 43 - Change password policy for tester3

Change the password policy for tester3 to require a new password every 10 days
```bash
sudo chage -M 10 tester3
```

## Exercise 44 - Set account expiry for users

Set the users account for tester1, tester2, tester3 to expire in 30 days
```bash
EXP_DATE=$(date -d "+30 days" +"%Y-%m-%d")
sudo chage -E $EXP_DATE tester1
sudo chage -E $EXP_DATE tester2
sudo chage -E $EXP_DATE tester3
```

## Exercise 45 - Set SELinux mode

Set selinux in enforcing/permissive mode

Check current mode:
```bash
sestatus
```

- **Enforcing mode**:
```bash
sudo setenforce 1
```
- **Permissive mode**:
```bash
sudo setenforce 0
```

## Exercise 46 - Allow httpd to access /var/www/html

Allow your web server httpd to access files at /var/www/html, Configure your SELinux to allow that.

1. View httpd service status:
```bash
systemctl status httpd
```
2. View security context of files:
```bash
ls -Z /var/www/html/*
```
3. Modify security context:
```bash
semanage fcontext -m -t httpd_sys_content_t "/var/www/html/file1"
restorecon -R -v /var/www/html/file1
```

## Exercise 47 - Firewalld allow port

Firewalld – allow port 8080 in public zone to be persistent after reboot

```bash
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
```


## Exercise 48 - Add file to all new users' home

All newly created users should have a file called "All-users" with the message "aaa" within their home directory.
```bash
echo "aaa" | sudo tee /etc/skel/All-users
```


## Exercise 49 - Find files with SGID under 10M

Find all files under /usr that are less than 10M and have sgid permissions set.

```bash
find /usr -size -10M -perm -2000 > /root/myfile
```

## Exercise 50 - Create Stratis pool and filesystem

Create a stratis pool of size 2GB with name newpool and create a filesystem with name newpart1 it should be mounted on /mnt/partition.

```bash
yum install stratisd stratis-cli
sudo systemctl enable stratisd
stratis pool create newpool /dev/sdb
stratis pool list
stratis filesystem newpool newpart1
stratis filesystem list
mkdir /mnt/partition
mount /stratis/newpool/newpart1 /mnt/partition
# Add to /etc/fstab for persistence
vim /etc/fstab
```

## Exercise 51 - Add user with non-expiring password

Add user Krish such that it's password not gonna expire.

```bash
useradd -f -1 Krish
```

## Exercise 52 - Expire accounts on Dec 31, 2021

Make accounts for user10 and user30 to expire on December 31, 2021.

```bash
chage --expiredate "2021-12-31" user10
chage --expiredate "2021-12-31" user30
```

## Exercise 53 - Mount RHEL ISO persistently

Attach the RHEL ISO image to the VM and mount it persistently to /mnt/cdrom.

```bash
mkdir /mnt/cdrom
echo "/rhel-8.3-x86_64-dvd.iso /mnt/cdrom iso9660 defaults 0 0" >> /etc/fstab
mount -a
```

## Exercise 54 - Create 300MB swap LV

Create a logical volume called lvswap of size 300MB in vgtest volume group. Initialize the logical volume for swap use. Use the UUID and place an entry for persistence.

```bash
lvcreate -n lvswap -L 300m vgtest
mkswap /dev/vgtest/lvswap
echo "UUID=xxxx-xxxx-xxxx-xxxx-xxxx swap swap defaults 0 0" >> /etc/fstab
swapon -a
swapon --show
```

## Exercise 55 - Configure atd access

Enable access to the atd service for user20 and deny for user30.

```bash
echo "user30" >> /etc/at.deny
echo "user20" >> /etc/at.allow
systemctl restart atd
```

## Exercise 56 - Script to create users with nologin

Write a bash shell script that creates three users: user555, user666, user777 with nologin shell and passwords matching their names. The script should also extract names of these three new users from the /etc/passwd and redirect them to /var/tmp/newusers.

```bash
#!/bin/bash
for i in {5..7}; do
  useradd user$i$i$i -s /sbin/nologin
  echo user$i$i$i:user$i$i$i | chpasswd
done
cut -d : -f1 /etc/passwd | tail -n 3 > /var/tmp/newusers
echo "Newly added users are:"
cat /var/tmp/newusers
```

## Exercise 57 - Create three users in instructors group

Create Three Users (Derek, Tom, and Kenny) that All Belong to the instructors Group. Prevent Tom's User from Accessing a Shell, and Make His Account Expire Ten Days from Now.

```bash
groupadd instructors
useradd derek -G instructors
useradd tom -G instructors -s /sbin/nologin -e $(date -d "+10days" +%F)
useradd kenny -G instructors
```

## Exercise 58 - Configure Apache to serve from /var/www

Download and Configure Apache to Serve index.html from /var/web and Access It from the Host Machine.

```bash
yum -y install httpd
systemctl enable --now httpd
vim /etc/httpd/conf/httpd.conf # change DocumentRoot to /var/www and relax access
systemctl restart httpd
systemctl status firewalld.service
firewall-cmd --add-service=http --permanent
firewall-cmd --reload
firewall-cmd --list-all
echo "this index page is coming from /var/www folder" >> /var/www/index.html
curl <host_ip>
```

## Exercise 59 - Find old files in /etc

Find All Files in /etc (Not Subdirectories) that Are Older Than 720 Days, and Output a List to /root/oldfiles.

```bash
find /etc -maxdepth 1 -mtime +720 -type f -exec cp {} /root/oldfiles \;
```

## Exercise 60 - LVM Basics and Extending

- Before any kind of operations on ***LVM*** it is good to know what we actually have in the system. The proper command to list all devices we can use is in order **pvs**, **vgs** and **lvs**. It shows all physical storages and devices, volume groups and logical volumes.
- Exam objectives require extending of logical partitions. The tricky part here is to remember that **XFS** filesystem (which is the default setting for RHEL) does not allow downsizing of **XFS** partition (the only possibility is to grow that volume). So please be careful when reading LVM related questions during the exam. EXT can both extend and shrink.
- List all LVM devices:
```bash
pvs
vgs
lvs
```
- Extend logical volume (XFS cannot shrink):
```bash
lvextend --size 200M -r /dev/VOLUME_GROUP/LOGICAL_VOLUME
```
- To label a logical volum (needs umount):
```bash
umount /LINK/TO/FILESYSTEM/MOUNT/POINT
xfs_admin -L "myFS" /dev/VOLUME_GROUP/LOGICAL_VOLUME
mount /LINK/TO/FILESYSTEM/MOUNT/POINT
```

## Exercise 61 - Set Default Boot Target to Graphical

Set the default target to boot into X Window level (previously level 5).

```bash
systemctl set-default graphical.target
systemctl get-default
```

## Exercise 62 - Reduce Logical Volume by 400MB

Reduce the size of existing logical volume by 400MB.

```bash
lvdisplay
umount /MOUNT_POINT
lvreduce -L -400M /dev/LINK_TO_LVM
mount -a
lvdisplay
```

## Exercise 63 - Persist Journald Logs

Configure journald to persist between reboots.

```bash
vim /etc/systemd/journald.conf  # change #Storage=auto to Storage=persistent
systemctl restart systemd-journald.service
```

## Exercise 64 - Password Expiration Policies

- user1 pass should expire every 10 days
- user2 pass should expire in 30days from the current date
- user3 pass should change their pass upon first login

```bash
sudo chage -M 10 user1
sudo chage -E $(date -d "+30 days" +%F) user2
sudo chage -d 0 user3
```

## Exercise 65 - Sticky Bit for Directory

Ensure only the owner of the directory or owner of the files within that directory can delete files within that directory.

```bash
sudo chmod +t /shared
```

## Exercise 66 - Set Default Boot Target to Multi-User

Set the default target the system should boot in to multi-user.target.

```bash
sudo systemctl set-default multi-user.target
```

## Exercise 67 - Firewall Default Zone

Set the default zone to public.

```bash
sudo firewall-cmd --set-default-zone=public
```

## Exercise 68 - Remote Transfer

Use SCP or Rsync or SFTP to transfer something

```bash
scp [options] <source> <destination>
```

## Exercise 69 - Stratis Storage Stack

1. Install the stratisd service and cli
2. Start the stratisd service 
3. Enable the stratisd service 
4. Create a stratis pool called pool1 
5. Create a stratis filesystem within pooll called fs1 
6. Create a directory called /mountstratis 
7. Persistently mount the stratis filesystem fs1 on /mountstratis using it's UUID

```bash
sudo dnf install stratisd stratis-cli -y
sudo systemctl enable --now stratisd
sudo stratis pool create pool1 /dev/sdb
sudo stratis filesystem create pool1 fs1
sudo mkdir /mountstratis
sudo mount /stratis/pool1/fs1 /mountstratis
blkid | grep stratis
# Add entry to /etc/fstab
UUID=xxxx-xxxx /mountstratis xfs defaults 0 0
sudo mount -a
```



