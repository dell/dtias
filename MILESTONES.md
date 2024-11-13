# Milestones

## Milestone 1 - Build Basic System Components 

- Create a YAML-based user input file. This user input file will be consumed and produce the Ansible inventory file 
- Write an Ansible playbook using Dell’s OME Ansible modules which fully updates a set of target servers via OME 
- Write an Ansible playbook using Dell’s OME Ansible modules which takes as input a list of servers and their profiles and applies appropriate BIOS templates via OME 
- Write Ansible playbook which deploys host for OME repositories (Apache, SMB, etc) 
- Write Ansible playbook which deploys RKE2  
- Write Ansible playbook which deploys OME VM to RKE2 or other platform 
- Write an Ansible playbook using Dell’s OME Ansible Modules which deploys OME host automation workflow 
- Write Ansible playbook to deploy DNS, NTP, and DHCP for the system 
- Create user required system profiles and integrate them with the OME automation workflow 
- Write code to dynamic generate the Ansible inventory file based on user requirements

## Milestone 2 - Build Deployment VM

- Write an Ansible playbook which builds the deployment VM OVA or other deployment mechanism and spins it up on KVM/other host 
- Write an Ansible playbook which installs DNS, NTP, and DHCP on the deployment VM 
- Write an Ansible playbook which deploys system deployment framework to the deployment VM 
- Write a test harness which confirms the system is working as expected after a build 

## Milestone 3 - Perform Integration Testing

- Perform integration testing against live servers with correct configurations 
- Perform integration testing with customer using a representative tester 
- Update documentation based on user feedback 
- Prepare for final delivery 

## Missing Things

- Hardware discovery to figure out which template we're going to apply
- Checking for app compatibility
- Implementing robust error handling for the users so they both have a way to see what failed, but also where it failed, and why
- Secure credential management
- A test phase for all the network stuff to make sure everything is actually up
- Post installation health checks
- Some sort of centralized logging