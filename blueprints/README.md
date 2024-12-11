# API Usage

## Step 1: Upload Blueprint Package

Upload the playbook package zip containing playbook files as well as the blueprint package to the file server using DTIAS Rest API:
POST https://dtiaf_ip/v1/tenants/default/fs/files/upload/{FolderPath}

Then upload the blueprint package to the DTIAS Orchestrator using DTIAS REST API:
POST https://dtiaf_ip/v1/tenants/default/blueprints/{BlueprintId}

## Step 2: Configure Blueprint Inputs

Modify the values in `bp-inputs.yaml` to match the values of your uploaded Ansible playbook and any other inputs you would like to overwrite. Ensure that the coresponding public key for your private key has been coppied to the target remote host (you can use ssh-keygen and ssh-copy-id to create and copy a new key if you do not already have one).

The playbook_source_url should be the URL to your uploaded playbook package and playbook_relative_path should specify the entrypoint relative to the root of the playbook package archive.

## Step 3: Create Deployment

Create a deployment using the uploaded blueprint via DTIAS REST API (refer to [DTIAS API usage guide](https://stoplight.dell.com/docs/fulcrum-rest-api-guide/d6a8ba3f3c186-introduction-dell-telecom-infrastructure-automation-foundation-1-1-rest-ap-is) on syntax):
POST https://dtiaf_ip/v1/tenants/default/deployments. Include your input values from `bp-inputs.yaml` inside the request body. After the deployment succeeds, you should see the desired effect of your Ansible playbook on your specified remote host.
