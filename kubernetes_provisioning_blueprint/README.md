# Kubernetes Provisioning Blueprint for RedHat Linux

## Overview
This repository contains a Cloudify blueprint for installing and provisioning a Kubernetes cluster on a RedHat Linux server. The blueprint automates the setup process, ensuring Kubernetes is installed and properly configured on the target server.

## Directory Structure
```
kubernetes_provisioning_blueprint/
├── blueprint.yaml                  # The main blueprint file (e.g., kubernetes_rh_cloudify.yaml)
├── scripts/
│   ├── create_vm.yml               # Ansible playbook to create the VM
│   ├── install_kubernetes.sh       # Bash script to install Kubernetes
│   ├── start_kubernetes.sh         # Bash script to start Kubernetes services
│   ├── stop_kubernetes.sh          # Bash script to stop Kubernetes services
│   └── delete_kubernetes.sh        # Bash script to delete/uninstall Kubernetes
└── README.md                       # Documentation on how to use the blueprint
```

## Prerequisites
- Cloudify Manager (version 7 or later)
- RedHat Linux server with sudo privileges
- Ansible installed for running the playbook

## Instructions

1. **Upload the Blueprint**
   Upload the blueprint to your Cloudify Manager:
   ```sh
   cfy blueprints upload -b kubernetes_blueprint blueprint.yaml
   ```

2. **Create a Deployment**
   Create a deployment from the uploaded blueprint:
   ```sh
   cfy deployments create -b kubernetes_blueprint kubernetes_deployment
   ```

3. **Install the Deployment**
   Install the deployment to provision the Kubernetes cluster:
   ```sh
   cfy executions start -d kubernetes_deployment install
   ```

## Scripts Overview
- **create_vm.yml**: Ansible playbook for creating the virtual machine.
- **install_kubernetes.sh**: Bash script to install Kubernetes components (kubelet, kubeadm, kubectl) and configure Docker.
- **start_kubernetes.sh**: Script to initialize Kubernetes using `kubeadm` and set up the Flannel network add-on.
- **stop_kubernetes.sh**: Script to stop Kubernetes services and reset the cluster.
- **delete_kubernetes.sh**: Script to delete Kubernetes components and clean up all related files.

## Outputs
- The IP address of the Kubernetes master node is available as an output (`kubernetes_master_ip`).

## Notes
- The Flannel network plugin is used for simplicity, but other network plugins can be configured as needed.
- The `kubectl` configuration is set up for the root user by default. Adjust as needed for other users.

## Troubleshooting
- Ensure that Docker and Kubernetes services are running if any issues arise during provisioning.
- Use `cfy logs download` to collect logs for debugging any Cloudify-specific issues.

