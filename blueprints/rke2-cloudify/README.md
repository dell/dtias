# RKE2 Provisioning Blueprint for RedHat Linux

## Overview
This repository contains a Cloudify blueprint for installing and provisioning an RKE2 cluster on multiple RedHat Linux servers using Ansible. The blueprint automates the setup process, ensuring RKE2 is installed and properly configured across the target servers.

## Directory Structure
```
rke2-cloudify/
├── blueprint.yaml                  # The main blueprint file 
├── resources/ansible/
│   ├── deploy-rke2.yml             # Ansible playbook to install RKE2
│   ├── rke2-start.yml              # Ansible playbook to start RKE2 services
│   ├── rke2-stop.yml               # Ansible playbook to stop RKE2 services
│   └── rke2-uninstall.yml          # Ansible playbook to delete/uninstall RKE2
├── hosts                           # Ansible inventory file listing all target hosts
├── group_vars/
│   └── rke2_nodes.yml              # Ansible group variables for the RKE2 nodes
└── README.md                       # Documentation on how to use the blueprint
```

## Prerequisites
- Cloudify Manager (version 7 or later)
- RedHat Linux servers with sudo privileges

## Instructions

**prerequisite**
* Setup passwordless ssh between the cloudify manager host and the remote servers.

* Upload the ssh private key into cloudify manager. The private key will be used to connect to the remote servers during the deployment.

   * If you are using the docker version of the cloudfiy manager, you can use the below command. Replace PATH_TO_SSH_PRIVATE_KEY and CONTAINER with the appropriate information


      ```sh
      docker cp <PATH_TO_SSH_PRIVATE_KEY> <CONTAINER>:/etc/cloudify/rke2-ssh.key
      ```

1. **Upload the Blueprint**
   Create zip file bundle of the blueprint
   ```sh
   zip -r rke2-cloudify.zip rke2-cloudify
   ```

   Upload the blueprint to your Cloudify Manager:
   ```sh
   cfy blueprints upload -b rke2_blueprint blueprint.zip
   ```
   
   Or you can upload the blueprint from a remote location

   ```sh
   cfy blueprints upload -b rke2_blueprint https://remote-server/blueprint.zip
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

## Playbook Overview
- **deploy-rke2.yaml**: Ansible playbook to install RKE2 components and configure services.
- **rke2-start.yaml**: Playbook to start RKE2 services and set up kubeconfig.
- **rke2-stop.yaml**: Playbook to stop RKE2 services.
- **rke2-uninstall**: Playbook to delete RKE2 components and clean up all related files.

## Outputs
- The IP address of the RKE2 master node is available as an output (`rke2_master_ip`).

## Notes
- The default configuration sets up tow RKE2 nodes, but this can be adjusted as needed.
- The `kubectl` configuration is set up for the root user by default. Adjust as needed for other users.

## Troubleshooting
- Ensure that RKE2 services are running if any issues arise during provisioning.
- Use `cfy logs download` to collect logs for debugging any Cloudify-specific issues.
