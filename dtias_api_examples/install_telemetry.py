import argparse
import json

import requests
import urllib3

# Disable SSL warnings globally
urllib3.disable_warnings()


def get_token(dtias_ip):
    token_url = "https://{}/identity/v1/tenant/Fulcrum/token/create".format(dtias_ip)
    token_payload = json.dumps(
        {"grant_type": "password", "client_id": "ccpapi", "username": "admin", "password": "Dell0SS!"})
    token_headers = {'Content-Type': 'application/json'}
    token_response = requests.request("POST", token_url, headers=token_headers, data=token_payload, verify=False)
    token_response_json = json.loads(token_response.content)
    print("Token Created")
    # print(token_response.content)
    return token_response_json['id_token']


def telemetry_file_upload(dtias_ip, telemetry_file_path):
    print("Initializing telemetry file upload")
    token = get_token(dtias_ip)
    telemetry_upload_url = "http://{}:80/put/data/applications".format(dtias_ip)
    # telemetry_upload_url = "http://{}/v1/tenants/default_tenant/fs/files/upload/applications".format(dtias_ip)
    files = [('file', (telemetry_file_path, open(telemetry_file_path, 'rb'), 'application/octet-stream'))]
    telemetry_upload_headers = {'Authorization': 'Bearer {}'.format(token)}
    telemetry_upload_response = requests.request("POST", telemetry_upload_url, headers=telemetry_upload_headers,
                                                 files=files, verify=False)
    print(telemetry_upload_response.content)


def telemetry_install(dtias_ip, telemetry_file_name):
    print("Initializing telemetry Install")
    token = get_token(dtias_ip)
    install = True
    telemetry_install_url = "https://{}/v1/tenants/default_tenant/application".format(dtias_ip)
    ApplicationPackageURL = "http://{}:80/data/applications/{}".format(dtias_ip, telemetry_file_name)
    telemetry_install_payload = json.dumps(
        {"ApplicationName": "telemetry", "ApplicationPackageURL": ApplicationPackageURL, "Install": install})
    print(telemetry_install_payload)
    telemetry_install_headers = {'Authorization': 'Bearer {}'.format(token)}
    telemetry_install_response = requests.request("POST", telemetry_install_url, headers=telemetry_install_headers,
                                                  data=telemetry_install_payload, verify=False)
    print(telemetry_install_response.content)
    print("Telemetry Install request completed")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--dtias_ip", required=True)
    parser.add_argument("--telemetry_file_path", required=True)
    parser.add_argument("--telemetry_file_name", required=True)
    args = parser.parse_args()
    dtias_ip = args.dtias_ip
    telemetry_file_path = args.telemetry_file_path
    telemetry_file_name = args.telemetry_file_name
    telemetry_file_upload(dtias_ip, telemetry_file_path)
    telemetry_install(dtias_ip, telemetry_file_name)
