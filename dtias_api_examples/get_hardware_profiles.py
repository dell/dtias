"""
#### Synopsis
Script to retrieve hardware profiles from DTIAS

#### Description
This script uses the DTIAS REST API to retrieve a list of hardware profiles. It authenticates using a token obtained 
via the API and retrieves the profiles associated with the specified tenant. 

#### Python Example
```bash
python get_hardware_profiles.py --server_ip <ip addr> --tenant_id <tenant> --username <username> --password <password>
```

where:

- server_ip is the IP address of the DTIAS server.
- tenant_id is the tenant name (default: metalweaver).
- username and password are the credentials for authentication.
"""

import argparse
import requests
import urllib3

# Disable SSL warnings globally
urllib3.disable_warnings()

def create_token(server_ip, tenant_id, username, password):
    """
    Creates an authentication token for the DTIAS server.

    Parameters:
        server_ip (str): The IP address of the DTIAS server.
        tenant_id (str): The tenant ID (e.g., "default_tenant").
        username (str): The username to authenticate with.
        password (str): The password for the username.

    Returns:
        str: The ID token for authentication.
    """
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
        return response.json().get("id_token")
    except requests.exceptions.RequestException as e:
        print(f"Error generating token: {e}")
        return None


def get_hardware_profiles(server_ip, tenant_id, id_token):
    """
    Retrieves the list of hardware profiles from the DTIAS server.

    Parameters:
        server_ip (str): The IP address of the DTIAS server.
        tenant_id (str): The tenant ID (e.g., "default_tenant").
        id_token (str): The ID token for authentication.

    Returns:
        list: A list of hardware profiles.
    """
    url = f"https://{server_ip}/api/v1/tenant/{tenant_id}/resources/hardwareprofiles"
    headers = {
        "accept": "application/json, text/plain, */*",
        "authorization": f"Bearer {id_token}",
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
    }

    try:
        response = requests.get(url, headers=headers, verify=False)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error retrieving hardware profiles: {e}")
        return None


if __name__ == "__main__":
    # Set up argparse
    parser = argparse.ArgumentParser(description="Retrieve hardware profiles from the DTIAS server.")
    parser.add_argument("--server_ip", required=True, help="The IP address of the DTIAS server.")
    parser.add_argument("--tenant_id", default="metalweaver", help="The tenant ID (e.g., 'default_tenant').")
    parser.add_argument("--username", required=True, help="The username to authenticate with.")
    parser.add_argument("--password", required=True, help="The password for the username.")

    # Parse arguments
    args = parser.parse_args()

    # Step 1: Generate an ID token
    id_token = create_token(args.server_ip, args.tenant_id, args.username, args.password)
    if not id_token:
        print("Failed to generate token. Exiting...")
        exit(1)

    # Step 2: Retrieve hardware profiles
    profiles = get_hardware_profiles(args.server_ip, args.tenant_id, id_token)
    if profiles:
        print("Hardware Profiles Retrieved Successfully:")
        print(profiles)
    else:
        print("Failed to retrieve hardware profiles.")
