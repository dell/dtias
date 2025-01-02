The steps here are to simplify the README.md processes and conditions to get a fully automated installation of Harvester. The README.md provides the details on what is happening under the hood. The SCRIPTS.md details the bash scripts and what each one is doing.

The released harvester iso image used to generate the usbInstaller has some bugs, which PRs have been submitted. In the meantime I have hosted on a Google Drive a patched base harvester iso image (6.5 GB):

https://drive.google.com/file/d/1y2fOt83dup1P6uzAYeZ2sDaiVGnLaf3q/view?usp=sharing

Need to download this and keep handy the location and filename if you change it. I did include a default path and filename as ./harvester-4f22d04-dirty-amd64.iso in the script user_config.sh which gets run from the MAKE.sh.

I work in a SUSE environment given Harvester is a SUSE product. I have included the RHEL/Rocky packages.

If you work under a non root account to get sudo working correctly with tool path when installed as you'll need to run the MAKE.sh as root.

You will need to update the secure_path in the sudoers file to include the path for hauler and helm.

edit /etc/sudoers or use visudo to include the following paths /usr/local/sbin:/usr/local/bin

Defaults    secure_path= "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"


Required tools to have installed htpasswd and xorriso.
    sudo yum install httpd-tools xorriso
    sudo zypper in apache2-utils xorriso

Need to install HELM and HAULER

 curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
 curl -sfL https://get.hauler.dev | sudo bash


The dell/dtias/usbInstaller is where I have placed everything.

The hauler-helm directory is also a patched chart repo to address another bug that has been submitted to Zach at Rancher.
For now we have to use this variant.

You'll need to package the hauler-helm to move that artifact to the harvesterAutomation directory.
    cd hauler-helm/charts
    helm package hauler
Move this artifact hauler-helm-1.1.1.tgz to
    mv hauler-helm-1.1.1.tgz ../../harvesterAutomation/registry.tar.gz
Edit the seeder_files located in harvesterAutomation/hauler/seeder_files.yaml, line 8 to point the hauler-helm  / registry path. 

    - path: file:///<path to>/harvesterAutomation/registry.tar.gz
      name: registry.tgz


To generate the usbInstaller.iso
cd <path to >/harvesterAutomation
sudo sh MAKE.sh

The Q&A you will be prompted with the first run will ask a series of question needed to setup/install the system. Here is a sample of what you'll see:

sudo sh MAKE.sh 
No existing variables file found. Entering setup mode.
Enter NTP Server IP address []: 192.1.1.1
Enter DNS Nameservers, comma-delimited []: 192.1.1.10
Enter Virtual IP ('vip') []: 192.1.1.101
Enter Linux Management Interface name [eno1]: 
Enter Host IP Address []: 192.1.1.100
Enter Host Subnet [255.255.255.0]: 
Enter Gateway IP Address []: 192.1.1.1
Enter cluster registration token [token1234]: 
Enter Host Root/Admin Password [root100]: 
Enter HostName (lowercase only, dashes only) [harvester-01]: 
Enter Disk Device Path for OS Install [/dev/sda]: 
Enter Disk Device Path for Data [/dev/sda]: 
Enter namespace to use for the Registry [registry]: 
Enter File name and Path to Harvester ISO [./harvester-4f22d04-dirty-amd64.iso]: 
Enter File name and Path to Installer ISO [./usbInstaller.iso]: 
Enter Label of ISO disc [harvester]: 

Current Values:
NTP Server IP: 192.1.1.1
DNS Nameservers: 192.1.1.10
Virtual IP: 192.1.1.101
Management Interface: eno1
Host IP Address: 192.1.1.100
Host Subnet: 255.255.255.0
Gateway IP Address: 192.1.1.1
Cluster Registration Token: token1234
Host Root/Admin Password: xxxxxxx
HostName: harvester-01
OS Install Disk Path: /dev/sda
Data Disk Path: /dev/sda
Namespace for Registry: registry
Stock Harvester ISO Path: ./harvester-4f22d04-dirty-amd64.iso
Output ISO Path: ./usbInstaller.iso
ISO Volume Label: harvester

Choose an option:
1. Modify values
2. Save and exit
Enter choice (1 or 2):

Once you are good with settings selecting option 2 will proceed to build the iso image.

Be sure you know the storage device names and the network device name or the harvester installer will fail. Working on some ideas how to do some discovery if there is an name mismatch. Currently the Rancher installer doesn't support this.

