# RKE2 Provisioning Blueprint for RedHat Linux

## Overview
This repository contains a Cloudify blueprint for installing and provisioning an RKE2 cluster on multiple RedHat Linux servers using Ansible. The blueprint automates the setup process, ensuring RKE2 is installed and properly configured across the target servers.

## Directory Structure
```
rke2_provisioning_blueprint/
├── blueprint.yaml                  # The main blueprint file (e.g., rke2_rh_cloudify.yaml)
├── scripts/
│   ├── create_vm.yml               # Ansible playbook to create the VMs
│   ├── install_rke2.yml            # Ansible playbook to install RKE2
│   ├── start_rke2.yml              # Ansible playbook to start RKE2 services
│   ├── stop_rke2.yml               # Ansible playbook to stop RKE2 services
│   └── delete_rke2.yml             # Ansible playbook to delete/uninstall RKE2
├── hosts                           # Ansible inventory file listing all target hosts
├── group_vars/
│   └── rke2_nodes.yml              # Ansible group variables for the RKE2 nodes
└── README.md                       # Documentation on how to use the blueprint
```

## Prerequisites
- Cloudify Manager (version 7 or later)
- RedHat Linux servers with sudo privileges
- Ansible installed for running the playbooks

## Instructions

1. **Upload the Blueprint**
   Upload the blueprint to your Cloudify Manager:
   ```sh
   cfy blueprints upload -b rke2_blueprint blueprint.yaml
   ```

2. **Create a Deployment**
   Create a deployment from the uploaded blueprint:
   ```sh
   cfy deployments create -b rke2_blueprint rke2_deployment
   ```

3. **Install the Deployment**
   Install the deployment to provision the RKE2 cluster:
   ```sh
   cfy executions start -d rke2_deployment install
   ```

## Scripts Overview
- **create_vm.yml**: Ansible playbook for creating the virtual machines.
- **install_rke2.yml**: Ansible playbook to install RKE2 components and configure services.
- **start_rke2.yml**: Playbook to start RKE2 services and set up kubeconfig.
- **stop_rke2.yml**: Playbook to stop RKE2 services.
- **delete_rke2.yml**: Playbook to delete RKE2 components and clean up all related files.

## Outputs
- The IP address of the RKE2 master node is available as an output (`rke2_master_ip`).

## Notes
- The default configuration sets up three RKE2 nodes, but this can be adjusted as needed.
- The `kubectl` configuration is set up for the root user by default. Adjust as needed for other users.

## Troubleshooting
- Ensure that RKE2 services are running if any issues arise during provisioning.
- Use `cfy logs download` to collect logs for debugging any Cloudify-specific issues.
