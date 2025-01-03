import argparse
import requests
import urllib3
import json

# Disable SSL warnings globally
urllib3.disable_warnings()


# Create a token for DTIAS server
def create_token(server_ip, tenant_id, username, password):
    url = f"https://{server_ip}/identity/v1/tenant/{tenant_id}/token/create"
    headers = {"Content-Type": "application/json"}
    data = {
        "grant_type": "password",
        "client_id": "ccpapi",
        "username": username,
        "password": password
    }

    try:
        response = requests.post(url, headers=headers, json=data, verify=False)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")
        return None


# Create a compute secret
def create_compute_secret(server_ip, tenant_id, id_token, secret_key, bmc_username, bmc_password):
    url = f"https://{server_ip}/v1/tenants/{tenant_id}/secrets"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {id_token}"
    }

    payload = {
        "Secrets": [
            {
                "Key": secret_key,
                "Value": json.dumps({"bmc_username": bmc_username, "bmc_password": bmc_password}),
                "Visibility": "tenant",
                "Tenant": tenant_id,
                "IsHiddenValue": False
            }
        ]
    }

    try:
        response = requests.post(url, headers=headers, json=payload, verify=False)
        response.raise_for_status()
        print("Compute secret created successfully.")
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error creating compute secret: {e}")
        return None


# Onboard compute resource
def onboard_compute_resource(server_ip, id_token, resource_data):
    url = f"https://{server_ip}/v1/tenants/default_tenant/resources"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {id_token}"
    }

    try:
        response = requests.post(url, headers=headers, json=resource_data, verify=False)
        response.raise_for_status()
        print("Compute resource onboarded successfully.")
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error onboarding compute resource: {e}")
        return None


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Onboard a compute resource to DTIAS.")
    parser.add_argument("--server_ip", required=True, help="The IP address of the DTIAS server.")
    parser.add_argument("--tenant_id", default="Fulcrum", help="The tenant ID (default: Fulcrum).")
    parser.add_argument("--username", required=True, help="The username to authenticate with.")
    parser.add_argument("--password", required=True, help="The password for authentication.")
    parser.add_argument("--secret_key", required=True, help="The key for the compute secret.")
    parser.add_argument("--bmc_username", required=True, help="BMC username for compute secret.")
    parser.add_argument("--bmc_password", required=True, help="BMC password for compute secret.")
    parser.add_argument("--resource_name", required=True, help="The name of the compute resource.")
    parser.add_argument("--resource_id", required=True, help="The ID of the compute resource.")
    parser.add_argument("--bmc_ip", required=True, help="IP address of the BMC.")
    parser.add_argument("--site_id", required=True, help="The Site ID for the compute resource.")

    args = parser.parse_args()

    # Step 1: Generate token
    tokens = create_token(args.server_ip, args.tenant_id, args.username, args.password)
    if not tokens:
        print("Failed to generate token. Exiting...")
        exit(1)

    id_token = tokens.get("id_token")

    # Step 2: Create the compute secret
    secret_response = create_compute_secret(
        args.server_ip, args.tenant_id, id_token,
        args.secret_key, args.bmc_username, args.bmc_password
    )

    if not secret_response:
        print("Failed to create compute secret. Exiting...")
        exit(1)

    # Step 3: Prepare resource data for onboarding
    resource_data = {
        "Resource": {
            "aState": "UNLOCKED",
            "BmoId": args.resource_id,
            "Description": "Imported Compute Resource",
            "GlobalAssetId": args.resource_id,
            "Id": args.resource_id,
            "Name": args.resource_name,
            "opState": "ENABLED",
            "public": "TRUE",
            "ResourcePoolId": "rp_dp",
            "ResourceTypeId": "rt_compute_dp",
            "ResType": "COMPUTE",
            "SiteId": args.site_id,
            "uState": "IDLE",
            "AdminState": "UNLOCKED",
            "UsageState": "IDLE",
            "ResourceProfileID": "",
            "ResourceAttribute": {
                "compute": {
                    "lom": {
                        "ipAddress": f"https://{args.bmc_ip}",
                        "password": args.secret_key
                    }
                }
            }
        }
    }

    # Step 4: Onboard compute resource
    onboard_response = onboard_compute_resource(
        args.server_ip, id_token, resource_data
    )

    if onboard_response:
        print("Compute resource onboarded successfully.")
        print(onboard_response)
    else:
        print("Failed to onboard compute resource.")
