# Debugging

1. Install the Remote - SSH Extension
   - In VSCode, install the *Remote - SSH* extension. This extension allows you to connect to a remote Linux server directly from your VSCode instance on Windows.
2. **Configure the Remote Connection in VSCode**:
   - Open VSCode, click on the Remote Explorer tab, and add your SSH configuration by following the prompts to connect to `user@linux-host`.
   - Once connected, you’ll have access to the Linux environment within VSCode, where you can install and configure `ansible-lint`.
3. **Install Ansible and Ansible-lint on the Linux Host**:
   - On your remote Linux machine (now accessible in the VSCode terminal), install Ansible and `ansible-lint`:
     ```bash
     sudo dnf install python3-pip -y
     pip3 install ansible ansible-lint
     ```
4. **Verify and Use Ansible-lint**:
   - In the terminal of your VSCode remote session, confirm `ansible-lint` is working:
     ```bash
     ansible-lint --version
     ```