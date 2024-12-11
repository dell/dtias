"""
#### Synopsis
Script to authenticate with DTIAS and retrieve resources.

#### Description
This script performs the following actions:
1. Authenticates with the DTIAS REST API using provided credentials.
2. Retrieves a list of resources based on optional filters and pagination parameters.

The script allows flexible filtering and pagination for resource retrieval, enabling efficient querying.

#### Python Example
```bash
python get_resources.py --server_ip <ip addr> --tenant_id <tenant> --username <username> \
--password <password> --filters '{"Key": "Value"}' --pagination '{"offset": 0, "limit": 10}'

where:

- server_ip is the IP address of the DTIAS server.
- tenant_id is the tenant name (default: Fulcrum).
- username and password are the credentials for authentication.
- filters specifies query filters as a JSON string (optional).
- pagination specifies pagination parameters as a JSON string (optional).
"""

import argparse
import requests
import urllib3

# Disable SSL warnings globally
urllib3.disable_warnings()

def create_token(server_ip, tenant_id, username, password):
    """
    Creates a token for the DTIAS server.

    Parameters:
        server_ip (str): The IP address of the DTIAS server.
        tenant_id (str): The tenant ID (e.g., "Fulcrum").
        username (str): The username to authenticate with.
        password (str): The password for the username.

    Returns:
        dict: A dictionary containing the access token, id token, and refresh token.
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
        response = requests.post(url, headers=headers, json=data, verify=False)  # Set verify=False for self-signed certs.
        response.raise_for_status()  # Raise an error for HTTP codes 4xx/5xx.
        return response.json()  # Return the JSON response with tokens.
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")
        return None

def get_resources(server_ip, tenant_id, id_token, filters=None, pagination=None):
    """
    Retrieves resources from the DTIAS server.

    Parameters:
        server_ip (str): The IP address of the DTIAS server.
        tenant_id (str): The tenant ID (e.g., "Fulcrum").
        id_token (str): The ID token for authentication.
        filters (list): List of filters for querying resources (optional).
        pagination (dict): Pagination parameters such as offset and limit (optional).

    Returns:
        dict: Resources data.
    """
    url = f"https://{server_ip}/v1/tenants/{tenant_id}/search/resources"
    headers = {
        "accept": "application/json, text/plain, */*",
        "authorization": f"Bearer {id_token}",
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
    }
    data = {}
    if filters:
        data["Filters"] = filters
    if pagination:
        data.update(pagination)

    try:
        response = requests.post(url, headers=headers, json=data, verify=False)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error retrieving resources: {e}")
        return None

if __name__ == "__main__":
    # Set up argparse
    parser = argparse.ArgumentParser(description="Retrieve resources from the DTIAS server.")
    parser.add_argument("--server_ip", required=True, help="The IP address of the DTIAS server.")
    parser.add_argument("--tenant_id", default="Fulcrum", help="The tenant ID (default: Fulcrum).")
    parser.add_argument("--username", required=True, help="The username to authenticate with.")
    parser.add_argument("--password", required=True, help="The password for the username.")
    parser.add_argument("--filters", help="Filters for querying resources as JSON string (optional).", default=None)
    parser.add_argument("--pagination", help="Pagination parameters as JSON string (optional).", default=None)

    # Parse arguments
    args = parser.parse_args()

    # Generate the token
    tokens = create_token(args.server_ip, args.tenant_id, args.username, args.password)
    if not tokens:
        print("Failed to generate token. Exiting...")
        exit(1)

    id_token = tokens.get("id_token")

    # Step 2: Retrieve resources
    filters = None
    if args.filters:
        try:
            filters = eval(args.filters)  # Safely parse JSON-like string
        except Exception as e:
            print(f"Error parsing filters: {e}")
            exit(1)

    pagination = None
    if args.pagination:
        try:
            pagination = eval(args.pagination)  # Safely parse JSON-like string
        except Exception as e:
            print(f"Error parsing pagination: {e}")
            exit(1)

    resources_data = get_resources(args.server_ip, args.tenant_id, id_token, filters, pagination)
    if resources_data:
        print("Resources Retrieved Successfully:")
        print(resources_data)
    else:
        print("Failed to retrieve resources.")
