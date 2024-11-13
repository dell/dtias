# Debugging

1. Build a Rocky Linux VM
2. Install the Remote - SSH Extension
   - On your host system, in VSCode, install the *Remote - SSH* extension. This extension allows you to connect to a remote Linux server directly from your VSCode instance
3. **Configure the Remote Connection in VSCode**:
   - Open VSCode, ctrl+shift+p, type ssh, click Remote-SSH Connect to Remote Host, follow the prompts to add your remote Linux host
   - Once connected, you’ll have access to the Linux environment within VSCode, where you can install and configure `ansible-lint`.
4. **Install Ansible and Ansible-lint on the Linux Host**:
   - On your remote Linux machine (now accessible in the VSCode terminal), install Ansible and `ansible-lint`:
     ```bash
     sudo dnf install python3-pip -y
     pip3 install ansible ansible-lint
     ```
5. **Verify and Use Ansible-lint**:
   - In the terminal of your VSCode remote session, confirm `ansible-lint` is working:
     ```bash
     ansible-lint --version
     ```
