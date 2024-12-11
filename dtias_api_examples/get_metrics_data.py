import argparse
import requests
import urllib3

# Disable SSL warnings globally
urllib3.disable_warnings()

"""
#### Synopsis
Script to retrieve metrics data from DTIAS

#### Description
This script authenticates with the DTIAS REST API to retrieve metrics data for a specified resource. It supports 
optional filters and metric IDs to customize the query.

#### Python Example
```bash
python get_metrics_data.py --server_ip <ip addr> --tenant_id <tenant> --username <username> \
--password <password> --resource <resource_id> --metrics_filter '{"Key": "Value"}'
```
where:
- `server_ip` is the IP address of the DTIAS server.
- `tenant_id` is the tenant name (default: Fulcrum).
- `username` and `password` are the credentials for authentication.
- `resource` specifies the resource for which metrics are queried.
- `metrics_filter` specifies additional filters as a JSON string (optional).

The script workflow includes:
1. Generating an authentication token.
2. Using the token to retrieve metrics data for the specified resource.

#### Notes
- SSL warnings are disabled for environments with self-signed certificates.
- The script handles errors gracefully, providing useful error messages for failed requests.
"""

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

def get_metrics_data(server_ip, tenant_id, resource, id_token, metric_id=None, metrics_filter=None):
    """
    Retrieves metrics data from the DTIAS server.

    Parameters:
        server_ip (str): The IP address of the DTIAS server.
        tenant_id (str): The tenant ID (e.g., "Fulcrum").
        resource (str): The resource type to query metrics for.
        id_token (str): The ID token for authentication.
        metric_id (str): The ID of the specific metric to query (optional).
        metrics_filter (dict): Additional filter criteria for metrics (optional).

    Returns:
        dict: Metrics data.
    """
    url = f"https://{server_ip}/v1/tenants/Fulcrum/{resource}/metrics/query"
    headers = {
        "accept": "application/json, text/plain, */*",
        "authorization": f"Bearer {id_token}",
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
    }
    data = {}
    if metric_id:
        data["MetricId"] = metric_id
    if metrics_filter:
        data["MetricsFilter"] = metrics_filter

    try:
        response = requests.post(url, headers=headers, json=data, verify=False)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error retrieving metrics data: {e}")
        return None

if __name__ == "__main__":
    # Set up argparse
    parser = argparse.ArgumentParser(description="Retrieve metrics data from the DTIAS server.")
    parser.add_argument("--server_ip", required=True, help="The IP address of the DTIAS server.")
    parser.add_argument("--tenant_id", default="Fulcrum", help="The tenant ID (e.g., 'Fulcrum').")
    parser.add_argument("--resource", required=True, help="The resource type to query metrics for.")
    parser.add_argument("--username", required=True, help="The username to authenticate with.")
    parser.add_argument("--password", required=True, help="The password for the username.")
    parser.add_argument("--metric_id", help="The ID of the specific metric to query (optional).", default=None)
    parser.add_argument("--metrics_filter", help="Additional filter criteria for metrics as JSON string (optional).", default=None)

    # Parse arguments
    args = parser.parse_args()

    # Step 1: Generate the token
    tokens = create_token(args.server_ip, args.tenant_id, args.username, args.password)
    if not tokens:
        print("Failed to generate token. Exiting...")
        exit(1)

    id_token = tokens.get("id_token")

    # Step 2: Retrieve metrics data
    metrics_filter = None
    if args.metrics_filter:
        try:
            metrics_filter = eval(args.metrics_filter)  # Safely parse JSON-like string
        except Exception as e:
            print(f"Error parsing metrics_filter: {e}")
            exit(1)

    metrics_data = get_metrics_data(args.server_ip, args.tenant_id, args.resource, id_token, args.metric_id, metrics_filter)
    if metrics_data:
        print("Metrics Data Retrieved Successfully:")
        print(metrics_data)
    else:
        print("Failed to retrieve metrics data.")
