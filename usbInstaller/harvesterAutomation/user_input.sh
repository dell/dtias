#!/bin/bash

# Function to clear screen and display current values
display_values() {
    clear
    echo "Current Values:"
    echo "NTP Server IP: $ntp_servers"
    echo "DNS Nameservers: $dns_nameservers"
    echo "Virtual IP: $vip"
    echo "Management Interface: $mgmt_interface"
    echo "Host IP Address: $host_ip"
    echo "Host Subnet: $host_subnet"
    echo "Gateway IP Address: $host_gateway"
    echo "Cluster Registration Token: $token"
    echo "Host Root/Admin Password: $(echo $password | sed 's/./x/g')"
    echo "HostName: $hostname"
    echo "OS Install Disk Path: $os_disk_device"
    echo "Data Disk Path: $data_disk_device"
    echo "Namespace for Registry: $registry_ns"
    echo "Stock Harvester ISO Path: $stock_harv_iso"
    echo "Output ISO Path: $output_iso"
    echo "ISO Volume Label: $volume_id"
}

# Function to prompt for input with default values
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local variable="$3"
    read -p "$prompt [$default]: " input
    eval "$variable=${input:-$default}"
}

# Check if variables file exists and load it, otherwise continue with prompts
if [ -f "variables" ]; then
    echo "Loading existing variables file..."
    source variables
else
    echo "No existing variables file found. Entering setup mode."
    # Initial prompts for all variables with defaults
    prompt_with_default "Enter NTP Server IP address" "" "ntp_servers"
    prompt_with_default "Enter DNS Nameservers, comma-delimited" "" "dns_nameservers"
    prompt_with_default "Enter Virtual IP ('vip')" "" "vip"
    prompt_with_default "Enter Linux Management Interface name" "eno1" "mgmt_interface"
    prompt_with_default "Enter Host IP Address" "" "host_ip"
    prompt_with_default "Enter Host Subnet" "255.255.255.0" "host_subnet"
    prompt_with_default "Enter Gateway IP Address" "" "host_gateway"
    prompt_with_default "Enter cluster registration token" "token1234" "token"
    prompt_with_default "Enter Host Root/Admin Password" "root100" "password"
    prompt_with_default "Enter HostName (lowercase only, dashes only)" "harvester-01" "hostname"
    prompt_with_default "Enter Disk Device Path for OS Install" "/dev/sda" "os_disk_device"
    prompt_with_default "Enter Disk Device Path for Data" "/dev/sda" "data_disk_device"
    prompt_with_default "Enter namespace to use for the Registry" "registry" "registry_ns"
    prompt_with_default "Enter File name and Path to Harvester ISO" "./harvester-4f22d04-dirty-amd64.iso" "stock_harv_iso"
    prompt_with_default "Enter File name and Path to Installer ISO" "./usbInstaller.iso" "output_iso"
    prompt_with_default "Enter Label of ISO disc" "harvester" "volume_id"
fi

# Array of variable names matching the order in the menu
variables_array=(ntp_servers dns_nameservers vip mgmt_interface host_ip host_subnet host_gateway token password hostname os_disk_device data_disk_device registry_ns stock_harv_iso output_iso volume_id)

# Main loop for user interaction
while true; do
    display_values
    echo -e "\nChoose an option:"
    echo "1. Modify values"
    echo "2. Save and exit"
    read -p "Enter choice (1 or 2): " choice

    case $choice in
        1)
            clear
            echo -e "\nWhich value do you want to modify?\n"
            for i in "${!variables_array[@]}"; do
                echo "$(($i+1)). ${variables_array[$i]}"
            done
            read -p "Enter number (1-16): " num

            if [[ $num =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le 16 ]; then
                var=${variables_array[$((num-1))]}
                read -p "Enter new value for $var: " new_value
                eval "$var=\"$new_value\""
            else
                echo "Invalid option."
            fi
            ;;
        2)
            clear
            echo "Saving variables..."
            # Create or update the YAML file with user inputs
            cat <<EOF > variables
ntp_servers=$ntp_servers
coredns_advertised_ip=192.168.0.253
dns_nameservers=$dns_nameservers
vip=$vip
mgmt_interface=$mgmt_interface
host_ip=$host_ip
host_subnet=$host_subnet
host_gateway=$host_gateway
token=$token
password=$password
hostname=$hostname
os_disk_device=$os_disk_device
data_disk_device=$data_disk_device
registry_ns=$registry_ns
stock_harv_iso=$stock_harv_iso
output_iso=$output_iso
volume_id=$volume_id
EOF
            echo "Variables saved to 'variables' file."
            exit 0
            ;;
        *)
            echo "Invalid option. Please enter 1 or 2."
            ;;
    esac
done