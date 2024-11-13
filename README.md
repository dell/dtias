# Kickstart My OME

## Contributing

For required coding style and structure guidelines see [CONTRIBUTING.md](./CONTRIBUTING.md)

## Installation

```bash
sudo dnf install epel-release -y
sudo dnf install ansible -y
sudo dnf install -y python3-netaddr
ansible-galaxy collection install containers.podman
```