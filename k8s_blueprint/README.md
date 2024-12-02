### `README.md`

# Kubernetes Deployment with Cloudify

This project provides a Cloudify blueprint and associated resources for deploying and managing Kubernetes services. It uses Cloudify workflows to interact with a Kubernetes cluster, leveraging a `kubeconfig` file for authentication and Kubernetes YAML definitions for resource configuration.

---

## Directory Structure

```
k8s_blueprint/
├── blueprint.yaml                # Main Cloudify blueprint
├── inputs.yaml                   # Input file for deployment parameters
├── resources/                    # Directory for resource files
│   ├── kubeconfig                # Kubeconfig file for Kubernetes authentication
│   └── service-definition.yaml   # Kubernetes resource definition YAML file
├── workflows/                    # Custom workflow scripts
│   └── deploy.py                 # Workflow script for deploying Kubernetes resources
├── README.md                     # Documentation
```

---

## Prerequisites

1. **Cloudify Manager**: Ensure you have a working installation of Cloudify Manager.
2. **Kubernetes Cluster**: A Kubernetes cluster must be accessible, and a `kubeconfig` file must be available for authentication.
3. **Dependencies**:
   - Python packages: `kubernetes` and `pyyaml`
   - Install these packages in your environment if you plan to run custom workflows:
     ```bash
     pip install kubernetes pyyaml
     ```

---

## Setup

### 1. Configure the Resources

1. **Kubeconfig**: Replace the contents of `resources/kubeconfig` with your Kubernetes `kubeconfig` file.
2. **Service Definition**: Update `resources/service-definition.yaml` with your Kubernetes resource YAML definition.

### 2. Update Inputs

Edit `inputs.yaml` to specify deployment parameters. Example:

```yaml
master_ip: 192.168.1.100
kubeconfig: resources/kubeconfig
service_definition: resources/service-definition.yaml
```

---

## How to Deploy

### Using Cloudify CLI

1. **Install the Blueprint**:
   ```bash
   cfy install blueprint.yaml -i inputs.yaml
   ```

2. **Run Custom Workflow (Optional)**:
   If you want to use the custom workflow for deployment, run:
   ```bash
   cfy executions start deploy_k8s_resources -p kubeconfig=resources/kubeconfig -p resource_definition=resources/service-definition.yaml
   ```

---

## Custom Workflow Details

The custom workflow defined in `workflows/deploy.py` uses the Kubernetes Python client to deploy resources. It supports the following Kubernetes resource types:
- **Deployment**
- **Service**

### Extending the Workflow

To add support for additional Kubernetes resource types, modify the `deploy.py` script in the `workflows/` directory.

---

## Cleanup

To remove deployed resources, you can use Cloudify's uninstall command:
```bash
cfy uninstall blueprint.yaml -i inputs.yaml
```

Alternatively, delete the resources directly from the Kubernetes cluster using `kubectl`:
```bash
kubectl delete -f resources/service-definition.yaml
```

---

## Troubleshooting

1. **Authentication Issues**:
   Ensure the `kubeconfig` file is valid and has the correct credentials and access permissions.

2. **Resource Conflicts**:
   If resources already exist in the cluster, the deployment might fail. Either delete the existing resources or update their configurations.

3. **Custom Workflow Errors**:
   Check the Cloudify logs for detailed error messages:
   ```bash
   cfy logs download
   ```
