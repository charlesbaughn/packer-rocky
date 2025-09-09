packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
    vmware = {
      version = ">= 1.0.7"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

source "vsphere-iso" "rocky_linux" {
  # Connection to ESXi
  vcenter_server      = "10.69.1.7"           # Replace with your ESXi IP/hostname
  username            = "root"                   # ESXi username
  password            = "DUMMYDATA"     # Replace with your ESXi password
  insecure_connection = true                     # For self-signed certificates

  # VM Placement
  datacenter = "ha-datacenter"                   # Default datacenter name for standalone ESXi
  datastore  = "SSD_02"             # Replace with your datastore name
  host       = "10.69.1.7"                    # Same as vcenter_server for standalone ESXi

  # Network Configuration
  network_adapters {
    network      = "MNG"                  # Replace with your network name
    network_card = "vmxnet3"
  }

  # ISO Configuration
  #iso_url      = "https://dl.rockylinux.org/vault/rocky/9.4/isos/x86_64/Rocky-9.4-x86_64-dvd.iso"
  #iso_checksum = "sha256:e20445907daefbfcdb05ba034e9fc4cf91e0e8dc164ebd7266ffb8fdd8ea99e7"

# ISO Configuration
# To use a local ISO file, specify the local path instead of a URL.
# Example for Windows paths (use forward slashes or double backslashes):
 iso_paths = [
        "[freeNAS] Images/ISOs/Rocky/Rocky-9.6-x86_64-dvd.iso"
      ]
  communicator   = "ssh"
  ssh_username   = "root"
  ssh_password   = "SinaDUMMYDATA"
  ssh_timeout    = "30m"

  http_directory = "http"
  boot_wait      = "10s"
  boot_command = [
    "<up><wait><tab><wait>",
    " inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.cfg",
    "<enter><wait>"
  ]


  # # VM Configuration
  vm_name       = "rocky-linux-template"
  guest_os_type = "centos7_64Guest"             # Note: updated format for vSphere
  CPUs = 2
  cpu_cores = 1
  RAM = 2048

  storage {
    disk_size             = 80480
    disk_thin_provisioned = true
  }



  # Shutdown
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  sources = ["source.vsphere-iso.rocky_linux"]

  provisioner "shell" {
    inline = [
      "sudo dnf update -y --nobest",
      "sudo dnf install -y vim"
    ]
  }

  provisioner "file" {
    source      = "files\\puppetfirstrun"
    destination = "/tmp/puppetfirstrun"
 }

  provisioner "shell" {
    inline = [
        "sudo mv /tmp/puppetfirstrun /usr/local/sbin/puppetfirstrun",
        "sudo chmod +x /usr/local/sbin/puppetfirstrun"
    ]
 }
 # Copy the systemd service file
    provisioner "file" {
    source      = "files\\puppetfirstrun.service"
    destination = "/tmp/puppetfirstrun.service"
}

# Install and enable the systemd service
    provisioner "shell" {
    inline = [
        "echo 'Checking if service file exists in /tmp...'",
        "ls -la /tmp/puppetfirstrun.service",
        "echo 'Moving service file to systemd directory...'",
        "sudo mv /tmp/puppetfirstrun.service /usr/lib/systemd/system/puppetfirstrun.service",
        "echo 'Verifying service file was moved...'",
        "ls -la /usr/lib/systemd/system/puppetfirstrun.service",
        "echo 'Reloading systemd daemon...'",
        "sudo systemctl daemon-reload",
        "echo 'Enabling puppetfirstrun service...'",
        "sudo systemctl enable puppetfirstrun.service",
        "echo 'Checking service status...'",
        "sudo systemctl status puppetfirstrun.service --no-pager"
    ]
    }
}