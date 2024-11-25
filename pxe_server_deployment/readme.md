# Prerequisites

## Step 1: Generate SSH Private and Public Keys and copy

$ ssh-keygen 

press enter (default empty values) for all prompts

Change to the SSH directory
$ cd ~/.ssh

Display SSH Private key 
$ cat id_rsa

Copy the private key and paste it into the ssh_private_key file and press enter

Copy the Public Key into the remote host

$ ssh-copy-id username@remote_host

The above command will copy the public key into remote host at ~./ssh directory.
The remote host is nothing but the host machine(s) where you want to run the ansible script through cloudify

## Step 4: Update the hosts file

Modify the hosts file to have the remote host and user name information
Replace the following
remotehost_ipaddress
remotehost_username

## Step 5: Zip the folder

Compress the folder into zip

# Option 1: DTIAS GUI usage

## Step 1: Create Secret

Create secret with the below key and value.
Key:  ssh_private_key_secret   
Value: ssh_private_key         -- This must be the file name of the SSH Private Key which is in the zip file

## Step 2: Upload the blueprint

Go to SDK->Blueprints screen
Upload the compressed zip file (created in step #5) into the fileserver.


## Step 3: Create Deployment

Go to the create deployment screen. Do not skill Install.
Provide the inputs.
"site_yaml_relative_path":"playbook.yaml" 
"hosts_relative_path":"hosts"

# Option 2: API usage (Postman)

## Step 1: Create Secret
https://{{ip}}/v1/tenants/default_tenant/secrets                                                        
Body:

{
  "Secrets": [
    {
      "CreatedAt": "string",
      "CreatedBy": "string",
      "Key": "ssh_private_key_secret",                 
      "Value": "ssh_private_key",
      "Visibility": "tenant",
      "Tenant": "default_tenant",
      "UpdatedAt": "string",
      "IsHiddenValue": true
    }
  ]
}

## Step 2: Upload Blueprint
https://{{ip}}/v1/tenants/default_tenant/fs/files/upload/ansible
file: zipfile created by step #5

## Step 3: Create Blueprint
https://{{ip}}/v1/tenants/default_tenant/blueprints/ansible-blueprint
{
  "MainFileName": "blueprint.yaml",
  "BlueprintArchivePath": "ansible/zipfile",
  "Visibility": "tenant"
}

## Step 4: Create Deployment
https://{{ip}}/v1/tenants/default_tenant/deployments

Pre-request script:
const inputs = {    
    "site_yaml_relative_path":"playbook.yaml", "hosts_relative_path":"hosts", "ssh_private_key_secret" : "ssh_private_key"
}
pm.environment.set(
    'YOUR_ESCAPED_JSON_INPUTS',
    JSON.stringify(JSON.stringify(inputs))
);

Body:
{
  "Deployment": {
    "Id": "ansible-bp-deployment",
    "BlueprintId": "ansible-blueprint",
    "Inputs": {{YOUR_ESCAPED_JSON_INPUTS}},
    "Res": {
      "isPrivate": false,
      "visibility": "tenant",
      "description": "installs antivirus software package clamav"
    }
  }
}

## Step 5: Run Job
https://{{ip}}/v1/tenants/default_tenant/job
{
  "WorkflowId": "install",
  "DeploymentId": "ansible-bp-deployment",
  "Parameters": "",
  "Force": true,
  "Queue": true,
  "Schedule": "queue"
}