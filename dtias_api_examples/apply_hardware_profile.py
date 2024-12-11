"""
#### Synopsis
Script to retrieve and apply hardware profiles on servers using DTIAS

#### Description
This script uses the DTIAS REST API to:
1. Authenticate with the server and generate an authentication token.
2. Retrieve the list of available hardware profiles.
3. Apply a specified hardware profile to a given list of servers.

The script disables SSL warnings for ease of use in environments with self-signed certificates. It requires the user 
to specify the target hardware profile and the servers on which it should be applied.

#### Python Example
```bash
python apply_hardware_profile.py --server_ip <ip addr> --tenant_id <tenant> --username <username> \
--password <password> --profile_name <profile name> --servers <server1,server2>
```

where:

- server_ip is the IP address of the DTIAS server.
- tenant_id is the tenant name (default: Fulcrum).
- username and password are the credentials for authentication.
- profile_name specifies the name of the hardware profile to apply.

servers is a comma-separated list of server names to apply the profile to.
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
    # URL for token creation
    url = f"https://{server_ip}/identity/v1/tenant/{tenant_id}/token/create"
    headers = {"Content-Type": "application/json"}
    data = {
        "grant_type": "password",
        "client_id": "ccpapi",
        "username": username,
        "password": password
    }

    try:
        # Send POST request to obtain the token
        response = requests.post(url, headers=headers, json=data, verify=False)
        response.raise_for_status()
        return response.json().get("id_token")
    except requests.exceptions.RequestException as e:
        # Handle request exceptions
        print(f"Error generating token: {e}")
        return None


def get_hardware_profiles(server_ip, id_token):
    """
    Retrieves the list of hardware profiles from the DTIAS server.

    Parameters:
        server_ip (str): The IP address of the DTIAS server.
        id_token (str): The ID token for authentication.

    Returns:
        list: A list of hardware profiles.
    """
    # URL for retrieving hardware profiles
    url = f"https://{server_ip}/api/v1/tenant/metalweaver/resources/hardwareprofiles"
    headers = {
        "accept": "application/json, text/plain, */*",
        "authorization": f"Bearer {id_token}",
    }

    try:
        # Send GET request to retrieve hardware profiles
        response = requests.get(url, headers=headers, verify=False)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        # Handle request exceptions
        print(f"Error retrieving hardware profiles: {e}")
        return None


def apply_hardware_profile(server_ip, id_token, profile, servers):
    """
    Applies the selected hardware profile to the specified servers.

    Parameters:
        server_ip (str): The IP address of the DTIAS server.
        id_token (str): The ID token for authentication.
        profile (dict): The selected hardware profile to apply.
        servers (list): The list of server names.

    Returns:
        dict: Response from the server.
    """
    # Extract profile name and construct URL
    profile_name = profile['metadata']['name']
    url = f"https://{server_ip}/api/v1/tenant/metalweaver/resources/hardwareprofiles/{profile_name}"
    headers = {
        "Content-Type": "application/json+patch",
        "Authorization": f"Bearer {id_token}"
    }
    # Define the payload for the PATCH request
    payload = {
        "apiVersion": "mw.dell.com/v2",
        "kind": "HardwareProfile",
        "metadata": {
            "name": f"{profile_name}",
            "labels": {
                "site": "gc"
            }
        },
        "spec": {
            "apply": True,
            "preview": False,
            "serverList": [{"name": server, "namespace": "metalweaver"} for server in servers]
        }
    }

    # Print debugging information
    print(f"URL: {url}")
    print(f"Payload: {payload}")

    try:
        # Send PATCH request to apply the hardware profile
        response = requests.patch(url, headers=headers, json=payload, verify=False)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        # Handle request exceptions
        print(f"Error applying hardware profile: {e}")
        return None


if __name__ == "__main__":
    # Set up argparse for command-line argument parsing
    parser = argparse.ArgumentParser(description="Retrieve and apply hardware profiles.")
    parser.add_argument("--server_ip", required=True,
                        help="The IP address of the DTIAS server.")
    parser.add_argument("--tenant_id", default="Fulcrum", help="The tenant ID (default: Fulcrum).")
    parser.add_argument("--username", required=True, help="The username to authenticate with.")
    parser.add_argument("--password", required=True, help="The password for the username.")
    parser.add_argument("--profile_name", required=True,
                        help="The name of the hardware profile.")
    parser.add_argument("--servers", required=True, help="Comma-separated list of server names.")

    # Parse arguments
    args = parser.parse_args()
    server_list = [server.strip() for server in args.servers.split(",")]

    # Step 1: Generate a token
    id_token = create_token(args.server_ip, args.tenant_id, args.username, args.password)
    if not id_token:
        print("Failed to generate token. Exiting...")
        exit(1)

    # Step 2: Retrieve hardware profiles
    profiles = get_hardware_profiles(args.server_ip, id_token)
    if not profiles:
        print("Failed to retrieve hardware profiles. Exiting...")
        exit(1)

    # Step 3: Find the matching profile by name
    profiles_list = profiles.get("items", [])
    selected_profile = next((p for p in profiles_list if p["metadata"]["name"] == args.profile_name), None)
    if not selected_profile:
        print(f"No hardware profile found with the name '{args.profile_name}'. Exiting...")
        exit(1)

    # Step 4: Apply the hardware profile
    response = apply_hardware_profile(args.server_ip, id_token, selected_profile, server_list)
    if response:
        print("Hardware profile applied successfully!")
        print(response)
    else:
        print("Failed to apply hardware profile.")
