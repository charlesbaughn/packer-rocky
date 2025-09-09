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
  password            = "NULLLLLLLLL"     # Replace with your ESXi password
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
  iso_url      = "https://dl.rockylinux.org/vault/rocky/9.4/isos/x86_64/Rocky-9.4-x86_64-dvd.iso"
  iso_checksum = "sha256:e20445907daefbfcdb05ba034e9fc4cf91e0e8dc164ebd7266ffb8fdd8ea99e7"
  
  # SSH Configuration
  ssh_username     = "packer"
  ssh_password     = "packer"
  ssh_wait_timeout = "20m"
  
  # # VM Configuration
  vm_name       = "rocky-linux-template"
  # guest_os_type = "centos7_64Guest"             # Note: updated format for vSphere
  # disk_size     = 20480
  # memory        = 2048
  # cpus          = 2
  
  storage {
    disk_size             = 20480
    disk_thin_provisioned = true
  }
  

  
  # Shutdown
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  sources = ["source.vsphere-iso.rocky_linux"]

  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y vim"
    ]
  }
}