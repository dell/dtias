import argparse
import requests


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


def get_hardware_profiles(server_ip, id_token):
    """
    Retrieves the list of hardware profiles from the DTIAS server.

    Parameters:
        server_ip (str): The IP address of the DTIAS server.
        tenant_id (str): The tenant ID (e.g., "default_tenant").
        id_token (str): The ID token for authentication.

    Returns:
        list: A list of hardware profiles.
    """
    url = f"https://{server_ip}/api/v1/tenant/metalweaver/resources/hardwareprofiles"
    headers = {
        "accept": "application/json, text/plain, */*",
        "authorization": f"Bearer {id_token}",
    }

    try:
        response = requests.get(url, headers=headers, verify=False)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
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
    url = f"https://{server_ip}/api/v1/tenant/Fulcrum/resources/hardwareprofiles"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {id_token}"
    }
    payload = {
        "kind": "HardwareProfile",
        "metadata": {
            "name": profile['metadata']['name'],
            "labels": {
                "site": "gc"
            }
        },
        "spec": {
            "apply": True,
            "preview": False,
            "server": profile['spec']['server'],
            "serverList": [{"name": server, "namespace": "metalweaver"} for server in servers]
        }
    }

    print(f"URL: {url}")
    print(f"Payload: {payload}")

    try:
        response = requests.post(url, headers=headers, json=payload, verify=False)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error applying hardware profile: {e}")
        return None


if __name__ == "__main__":
    # Set up argparse
    parser = argparse.ArgumentParser(description="Retrieve and apply hardware profiles.")
    parser.add_argument("--server_ip", required=True, help="The IP address of the DTIAS server.")
    parser.add_argument("--tenant_id", default="Fulcrum", help="The tenant ID (default: Fulcrum).")
    parser.add_argument("--username", required=True, help="The username to authenticate with.")
    parser.add_argument("--password", required=True, help="The password for the username.")
    parser.add_argument("--profile_name", required=True, help="The name of the hardware profile.")
    parser.add_argument("--servers", required=True, help="Comma-separated list of server names.")

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

    # Step 3: Find the matching profile
    profiles_list = profiles.get("items", [])

    # Find the matching profile by name
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
