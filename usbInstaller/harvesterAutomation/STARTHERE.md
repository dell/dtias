
# Automated Harvester Installation Guide

This guide simplifies the process for setting up a fully automated installation of Harvester. It details the steps, conditions, and scripts involved.

## Overview

- **README.md**: Provides an in-depth explanation of what happens during the installation process.
- **SCRIPTS.md**: Describes each bash script and its functionality.

## Pre-requisites

### Harvester ISO Image

The released Harvester ISO image for generating the `usbInstaller` contains known bugs, for which PRs have been submitted. A patched version is available:

- **Download Link**: [Google Drive Patched Harvester ISO](https://drive.google.com/file/d/1y2fOt83dup1P6uzAYeZ2sDaiVGnLaf3q/view?usp=sharing)
- **Size**: 6.5 GB
- **Default Path in Script**: `./harvester-4f22d04-dirty-amd64.iso` (as set in `user_config.sh`, run by `MAKE.sh`).

### Environment Setup

- **Operating System**: This guide assumes a RHEL/Rocky environment, I did my work under SUSE and included packages as well.
- **User Permissions**: If you're not running as root, ensure `sudo` is configured correctly:
  - Update `secure_path` in `/etc/sudoers` or via `visudo`:
    ```bash
    Defaults    secure_path= "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    ```

### Required Tools

Install the following tools:

- **For RHEL/Rocky**:
  ```bash
  sudo yum install httpd-tools xorriso

- **For SUSE**:
  ```bash
  sudo zypper in apache2-utils xorriso

### Additional Software
- **HELM**: 
  ```bash
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

- **HAULER**: 
  ```bash
  curl -sfL https://get.hauler.dev | sudo bash

### Directory Structure
- **usbInstaller**: Located at dell/dtias/usbInstaller.
- **hauler-helm**: Also required a patch to fix a condition/bug. Not yet in mainline. So I had to include it in our repo for now.

### Hauler-Helm Setup
- **Package Hauler-Helm**:
  ```bash
  cd hauler-helm/charts
  helm package hauler
- **Move Artifact**:
  ```bash
  mv hauler-helm-1.1.1.tgz ../../harvesterAutomation/registry.tar.gz
- **Update seeder_files.yaml**:
  Edit harvesterAutomation/hauler/seeder_files.yaml, line 8 to:
  ```yaml
  - path: file:///<path to>/harvesterAutomation/registry.tar.gz
    name: registry.tgz

### Creating the USB Installer
- **To generate usbInstaller.iso**:
  ```bash
  cd <path to>/harvesterAutomation
  sudo sh MAKE.sh

- **First Run**:
When you first run MAKE.sh, you will be prompted for the following information:
  ```bash
  sudo sh MAKE.sh 
  No existing variables file found. Entering setup mode.
  Enter NTP Server IP address []:
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
  
  Modify Values: Option 1 allows you to revise any settings.
  Save and Exit: Option 2 will finalize your settings and proceed to build the ISO.

- **Notes**:
Ensure you know the correct storage and network device names; otherwise, the Harvester installer might fail. Work is ongoing to improve device name discovery.
