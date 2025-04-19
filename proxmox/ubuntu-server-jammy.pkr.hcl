# Ubuntu Server jammy
# ---
# Packer Template to create an Ubuntu Server (jammy) on Proxmox

# Variable Definitions
# variable "proxmox_api_url" {
#     type = string
# }

# variable "proxmox_api_token_id" {
#     type = string
# }

# variable "proxmox_api_token_secret" {
#     type = string
#     sensitive = true
# }

# Resource Definiation for the VM Template
source "proxmox-iso" "ubuntu-server-focal" {

    # Proxmox Connection Settings
    proxmox_url = {YOUR_PROXMOX_SERVER_URL}
    username = {{YOUR_USERNAME}}
    token = {{YOUR_API_TOKEN_FOR_PROXMOX}}
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true

    # VM General Settings
    node = "proxmox"
    vm_id = "999"
    vm_name = "ubuntu-server-focal"
    template_description = "Ubuntu Server Focal Image"

    # VM OS Settings
    # (Option 1) Local ISO File
    boot_iso {
      type = "scsi"
      iso_file = "local:iso/ubuntu-20.04.2-live-server-amd64.iso"
    # - or -
    # (Option 2) Download ISO
    # iso_url = "https://releases.ubuntu.com/22.04/ubuntu-22.04-live-server-amd64.iso"
    # iso_checksum = "84aeaf7823c8c61baa0ae862d0a06b03409394800000b3235854a6b38eb4856f"
      unmount = true
      iso_checksum = "3d518612aabbdb77fd6b49cb55b824fed11e40540e4af52f5f26174257715c93740f83079ea618b4d933081f0b1bc69d32b7885b7c75bc90da5ad3fe1814cfd4"
    }
    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "50G"
        format = "raw"
        storage_pool = "local-lvm"
        storage_pool_type = "lvm"
        type = "virtio"
    }

    # VM CPU Settings
    cores = "2"

    # VM Memory Settings
    memory = "4096"

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    }

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "local-lvm"

    # PACKER Boot Commands
    boot_command = [
      "c",
      "linux /casper/vmlinuz --- autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ip=172.18.6.105::172.18.6.254:ubuntu-server:ens18:off ---<wait>",
      "<enter><wait>",
      "initrd /casper/initrd<enter><wait>",
      "boot<enter>"
    ]
    boot = "c"
    boot_wait = "10s" 

    # PACKER Autoinstall Settings
    http_directory = "http"
    # (Optional) Bind IP Address and Port
    #http_bind_address = "172.18.6.103"
    #http_port_min = 8802
    #http_port_max = 8802

    ssh_username = "soumith"

    # (Option 1) Add your Password here
    # ssh_password = "your-password"
    # - or -
    # (Option 2) Add your Private SSH KEY file here
    ssh_private_key_file = "~/.ssh/id_rsa"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "20m"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-focal"
    sources = ["proxmox-iso.ubuntu-server-focal"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    # Add additional provisioning scripts here
    # ...
}
