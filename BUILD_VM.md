# How to Build DTIAS VM

- Install Ubuntu 20.04 LTS
- Save and run the following script:

```bash
USER="adminuser"

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl pigz
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

- Run `pigz -dc DTIAS-bundle-v2.1.0.tar.gz | tar -xvf -` to unzip the DTIAS archive.
  - You will need to get the DTIAS archive from Dell.
- After you extract the archive you will need to edit `dtias_config.yaml`
- Below is a sample config for deploying a single node

```yaml
ha:
  enabled: false
  # vip is mandatory if ha is enabled (regardless of single or dualstack)
  # vip6 is optional and will be used for dualstack setup only alongside vip
  # e.g. For dualstack setup, we can have
  # vip: 1.2.3.4 and vip6:
  # or
  # vip: 1.2.3.4 and vip6: 1:2::3:4
  vip: 1.2.3.4
  vip6: 1:2::3:4
  storage_path: "/longhorn/"

# Set to true to restore DTIAF core services from a backup
restore_enabled: false
# Default timeout in seconds for the restore to finish
restore_timeout: 3600
# Region where the backup bucket is located. Optional
backup_storage_region: minio
# Name of the backup from which the restore will be.
backup_name: "replace-backup-name"
# Name of the backup storage location e.g. "default-backup-location"
backup_storage_location:
# Name the bucket where the backup is stored
backup_bucket_name: "replace-bucket"
# Url of where the backup is located. e.g. http://localhost:9000
backup_storage_url:
# Your AWS access key
velero_aws_access_key: "replace-access-key"
# Your AWS secret key
velero_aws_secret_key: "external_secretkey"
# Base64 encoded content of ca cert file
velero_ca_string: ""

# Do not change this username and password changing password not supported
opensearch_username: "admin"
opensearch_password: "myStrongPassword123@456"

# KMS Configuration

# Set to true to enable storage of secrets in a Key Management Service (KMS).
enable_kms: false
# Specify the KMS provider's name (e.g., "vault"). Leave empty if not using a KMS.
kms_provider: ""
# Define the IP address of the Key Management Service (KMS) host. e.g "http://1.2.3.8:8200"
kms_address: ""
# Provide the day-0 token required for communication with the Key Management Service (KMS).
kms_token: ""
# Provide the dedicated DTIAS namespace to use in the KMS
kms_namespace: ""
# Base64 encoded content of ca cert file for vault server
kms_ca_string: ""

# default admin user
dtias_admin_user: "adminuser"
# password for the admin user
dtias_admin_password: "yourpassword"
keycloak_hostname: "dtias"

license_file: ""

# edit install type to "RHOCP" if installing DTIAS on RHOCP cluster else ignore.
install_type: ""

# rhocp password is rhocp cluster kubadmin password
rhocp_password: "password"

# rhocp url is ocp cluster name in format <ocp cluster name>.demo.lab eg:- r19.demo.lab
rhocp_url: "<clustername>.demo.lab"

enable_tls13_only: true

resources:
  # bastion node for rhocp
  # - id: "CP0"
  #   username: "user"
  #   ipaddress: "1.2.3.9"
  #   password: "password"
  #   role: bastion
  # Controller node (exactly 1 required regardless of ha enable)
  - id: "CP1"
    username: "adminuser"
    ipaddress: "10.10.25.210"
    password: "yourpassword"
    role: controller
 # ha nodes (exactly 2 required in case of ha enabled set to true, 0 required in case of ha enabled set to false)
 #  - id: "CP2"
 #   username: "user"
 #   ipaddress: "1.2.3.6"
 #   password: "password"
 #   role: ha
 # - id: "CP3"
 #   username: "user"
 #   ipaddress: "1.2.3.7"
 #   password: "password"
 #   role: ha
  # add worker node, optional
  # - id: "John-Doe-2-RG"
  #   username: "user"
  #   ipaddress: "1.2.3.4"
  #   password: "password"
  #   role: worker
  # remove worker node, optional
  # - id: "John-Doe-3-RG"
  #   username: "user"
  #   ipaddress: "1.2.3.5"
  #   password: "password"
  #   role: worker_remove

bmp_config:
  bmpnode_id: bmonode_dp #bmp node resourece
  Location:
    Id: gc
    Name: gc
    Address:
      City: Round Rock
      Country: United States of America
      State: Texas
      Street: 501 Dell Way
    Coordinates:
      Latitude: '30.48421164465075'
      Longitude: '-97.66330717434248'
    Description: Dell Headquarters
    GlobalLocationId: gc # should be same as bmo node resource
  site:
    id: gc-site # this will be the global site name for bmp
    description: office site
    res:
      visibility: tenant
      isPrivate: false
    bmoSiteAttributes:
      # DHCP Enable is work in progress
      # Uncomment the below lines to enable DHCP
      # dhcpConfig:
      #   defaultLeaseTime: 0
      #   dhcpSubnets: []
      #   dns: ""
      #   domain: ""
      #   interfaces: ""
      #   maxLeaseTime: 0
      #   vendorClassIds: []
      # dhcpRelayConfig:
      #   dhcpForwardAddress: ""  # Forwarding address
      #   interfaces: ""          # Interface names
      dhcpDeployMode: none
      nodeName: flcm-ha-setup4-cp1  # node name of first controller
    address:
      street: 5450 Great America Pkwy
      city: Malibu
      state: California
      country: USA
    coordinates:
      latitude: 37.404882
      longitude: -121.978486
    Labels: []
  resourcePool:
    Description: This is resource pool
    Id: rp_dp
    Name: rp_dp

dualstack: false

# Optional CIDR configuration for ipv4 only cluster
# If cluster_cidr and service_cidr are not set explicitly, they should use the default settings. i.e 10.42.0.0/16 and 10.43.0.0/16
# Uncomment the below lines to enable custom CIDR configuration with updated values. (Currently only /16 subnet is tested in this installer)
# cluster_cidr: "172.27.0.0/16"
# service_cidr: "172.28.0.0/16"
```

- After you have set up your config, run `make install`. If something goes wrong and you want to try again, you can run `make uninstall` and then rerun `make install`
