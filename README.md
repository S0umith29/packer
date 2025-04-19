# Proxmox Packer Template for Ubuntu Server Jammy

This repository contains a Packer template to create an Ubuntu Server Jammy (22.04) virtual machine template on a Proxmox VE hypervisor. The template uses Cloud-Init for automated provisioning and configuration.

## Prerequisites

Before using this template, ensure you have the following:

- **Proxmox VE** installed and configured.
- **Packer** installed on your local machine.
- Access to the Proxmox API with a valid user and token.
- An Ubuntu Server Jammy ISO file uploaded to the Proxmox storage or accessible via a URL.
- SSH key for provisioning (`~/.ssh/id_rsa` by default).

## Repository Structure

```
proxmox/
├── files/
│   └── 99-pve.cfg          # Cloud-Init configuration file
├── http/
│   └── user-data           # Cloud-Init user data for autoinstall
├── proxmox.pkr.hcl         # Packer plugin configuration
└── ubuntu-server-jammy.pkr.hcl  # Main Packer template
```


## Configuration

### `proxmox.pkr.hcl`

This file configures the required Packer plugin for Proxmox.

### `ubuntu-server-jammy.pkr.hcl`

This is the main Packer template that defines:

- **Proxmox Connection Settings**: API URL, username, and token.
- **VM Settings**: CPU, memory, disk, and network configurations.
- **ISO Settings**: Local ISO file or download URL for Ubuntu Server Jammy.
- **Cloud-Init**: Automated installation using `autoinstall` and Cloud-Init.
- **Boot Commands**: Custom boot commands for unattended installation.
- **Provisioning**: Shell scripts and file uploads for post-installation setup.

Key configurations:

- VM ID: `999`
- VM Name: `ubuntu-server-focal`
- Disk Size: `50G`
- Memory: `4096 MB`
- Cores: `2`
- Network: `virtio` adapter on `vmbr0`
- SSH Username: `soumith`
- SSH Key: `~/.ssh/id_rsa`

### `http/user-data`

This file contains the Cloud-Init `autoinstall` configuration served over HTTP during the installation process.

### `files/99-pve.cfg`

This Cloud-Init configuration file is copied to the VM to ensure compatibility with Proxmox's Cloud-Init integration.

## Usage

1. **Clone the Repository**:

   ```bash
   git clone <repository-url>
   cd <repository-directory>/proxmox

2. **Update Configuration**:

    - Modify ubuntu-server-jammy.pkr.hcl to update Proxmox API credentials, ISO settings, or VM configurations as needed.
    - Ensure the http/user-data file is configured for your environment.
    - Update the SSH key path or password if necessary.

3. **Initialize Packer**:

```packer init```

4. **Build the tempate**:

```packer build ubuntu-server-jammy.pkr.hcl

   - This will create a VM template named ubuntu-server-focal on your Proxmox node.


