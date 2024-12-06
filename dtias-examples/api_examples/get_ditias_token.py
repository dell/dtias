import argparse
import requests


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


if __name__ == "__main__":
    # Set up argparse
    parser = argparse.ArgumentParser(description="Generate a token for the DTIAS server.")
    parser.add_argument("--server_ip", required=True, help="The IP address of the DTIAS server.")
    parser.add_argument("--tenant_id", default="Fulcrum", help="The tenant ID (default: Fulcrum).")
    parser.add_argument("--username", required=True, help="The username to authenticate with.")
    parser.add_argument("--password", required=True, help="The password for the username.")

    # Parse arguments
    args = parser.parse_args()

    # Generate the token
    tokens = create_token(args.server_ip, args.tenant_id, args.username, args.password)
    if tokens:
        print("Tokens created successfully!")
        print("Access Token:", tokens.get("access_token"))
        print("ID Token:", tokens.get("id_token"))
        print("Refresh Token:", tokens.get("refresh_token"))
    else:
        print("Failed to create tokens.")
