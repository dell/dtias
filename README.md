# DTIAS Examples

## Contributing

For required coding style and structure guidelines see [CONTRIBUTING.md](./CONTRIBUTING.md)

## Installation

```bash
sudo dnf install epel-release -y
sudo dnf install ansible -y
sudo dnf install -y python3-netaddr
ansible-galaxy collection install containers.podman
```

## Install DTIAS on Ubuntu 20.04

As user do the following (do not use root):

```bash
USER="grant"

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
sudo systemctl daemon-reload
sudo systemctl restart docker.service
sudo apt-get install -y make ntp ntpdate open-iscsi bash curl util-linux grep gawk nfs-common jq coreutils python3-pip net-tools
sudo systemctl enable ntp
sudo systemctl start ntp
sudo systemctl status ntp
sudo ntpdate -u time.google.com

# Append the required configuration to /etc/sysctl.conf if not already present
sudo tee -a /etc/sysctl.conf > /dev/null <<EOL
fs.inotify.max_user_watches = 1048576
fs.inotify.max_user_instances = 8192
vm.max_map_count = 262144
EOL

# Apply the changes immediately
sudo sysctl -p

CMND_ALIAS="Cmnd_Alias BIN=/bin/sh,/var/lib/rancher/rke2/bin/crictl,/usr/bin/systemctl,/usr/sbin/lvm,/usr/bin/mkdir,/usr/bin/touch,/usr/bin/tee,/usr/bin/sed,/usr/bin/umount,/usr/bin/mount,/usr/bin/rmdir,/usr/sbin/mkfs.xfs,/usr/sbin/lvs,/usr/sbin/pvcreate,/usr/sbin/pvremove,/usr/sbin/vgcreate,/usr/sbin/vgdisplay,/usr/sbin/vgremove,/usr/sbin/lvcreate,/usr/sbin/lvremove,/usr/bin/awk,/usr/bin/chown,/usr/bin/chmod,/usr/bin/echo,/usr/bin/cat,/usr/bin/cp,/usr/bin/rm,/bin/systemctl,/bin/mkdir,/bin/sed,/bin/umount,/bin/rmdir,/sbin/mkfs.xfs,/bin/chown,/bin/chmod,/bin/echo,/bin/cat,/bin/cp,/bin/rm,/usr/bin/docker,/usr/local/bin/helm"

# Create a new sudoers file
echo "$CMND_ALIAS" | sudo tee /etc/sudoers.d/custom-sudoers > /dev/null
echo "$USER ALL=NOPASSWD: BIN" | sudo tee -a /etc/sudoers.d/custom-sudoers > /dev/null

# Ensure proper permissions for the sudoers file
sudo chmod 440 /etc/sudoers.d/custom-sudoers

# Validate the sudoers configuration to ensure no syntax errors
sudo visudo -cf /etc/sudoers.d/custom-sudoers
if [ $? -ne 0 ]; then
    echo "Error: The sudoers file contains syntax errors."
    exit 1
else
    echo "Passwordless sudo for $USER configured successfully."
fi
```

## Install DTIAS on RHEL

Run the following. Make sure to replace the username with whatever user you're going to use for DTIAS

```bash
sudo dnf update -y
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install -y epel-release
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin make wget curl util-linux grep gawk nfs-utils jq coreutils python3-pip net-tools https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo systemctl enable --now docker
sudo usermod -aG docker gcurell # REPLACE THIS WITH YOUR INSTALL USER
sudo sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0|' /lib/systemd/system/docker.service
# TODO - maybe change to sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 -H tcp://0.0.0.0:2376|' /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker.service
```

Create the following script and run it.

```bash
#!/bin/bash
# Stopping firewalld
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# installing and enabling ufw
dnf makecache
dnf install -y ufw
sudo systemctl enable ufw
sudo systemctl start ufw

# disabling and reseting firewall before setting firewall rules
ufw disable
ufw --force reset

ufw allow SSH
ufw allow 443/tcp
ufw allow 80/tcp
ufw allow 442/tcp
ufw allow 82/tcp

# overcloudregistry.io port
ufw allow 5113/tcp

# docker port
ufw allow 2375/tcp
# used for Kubernetes API
ufw allow 6443/tcp

# used for node registration in k8's
ufw allow 9345/tcp

# required for flannel
ufw allow 8472/udp

# used by kublet
ufw allow 10250/tcp

# etcd client port
ufw allow 2379/tcp

# etcd peer port
ufw allow 2380/tcp

# NodePort port range
ufw allow 30000:32767/tcp
# Chrony (ntp) port

ufw allow 123/udp

# enabling and reloading the firewall
ufw --force enable
ufw reload

# reloading docker
sudo systemctl daemon-reload
sudo systemctl restart docker.service
sleep 5s

# rebooting the machine
reboot
```

Next run the following. Make sure to set the username appropriately:

```bash
# Set the username variable
USERNAME="gcurell"

sudo bash -c "echo -e 'fs.inotify.max_user_watches = 1048576\nfs.inotify.max_user_instances = 8192\nvm.max_map_count = 262144' >> /etc/sysctl.conf && sysctl -p"

# Define the command alias and passwordless sudo for the specified user
sudo bash -c "echo 'Cmnd_Alias BIN=/usr/bin/systemctl,/usr/sbin/lvm,/usr/bin/mkdir,/usr/bin/touch,/usr/bin/tee,/usr/bin/sed,/usr/bin/umount,/usr/bin/mount,/usr/bin/rmdir,/usr/sbin/mkfs.xfs,/usr/sbin/lvs,/usr/sbin/pvcreate,/usr/sbin/pvremove,/usr/sbin/vgcreate,/usr/sbin/vgdisplay,/usr/sbin/vgremove,/usr/sbin/lvcreate,/usr/sbin/lvremove,/usr/bin/awk,/usr/bin/chown,/usr/bin/chmod,/usr/bin/echo,/usr/bin/cat,/usr/bin/cp,/usr/bin/rm,/usr/bin/install,/bin/install,/bin/systemctl,/bin/mkdir,/bin/sed,/bin/umount,/bin/rmdir,/sbin/mkfs.xfs,/bin/chown,/bin/chmod,/bin/echo,/bin/cat,/bin/cp,/bin/rm,/usr/bin/yum,/bin/yum,/bin/sh' >> /etc/sudoers"

```
