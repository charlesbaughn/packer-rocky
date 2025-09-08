packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
    vmware = {
      version = ">= 1.0.7"
      source  = "github.com/hashicorp/vmware"
    }
  }
}


source "vmware-iso" "rocky_linux" {
  iso_url            = "https://dl.rockylinux.org/vault/rocky/9.4/isos/x86_64/Rocky-9.4-x86_64-dvd.iso"   // Replace with actual ISO URL
  iso_checksum       = "sha256:e20445907daefbfcdb05ba034e9fc4cf91e0e8dc164ebd7266ffb8fdd8ea99e7" // Replace with actual checksum
  ssh_username       = "packer"
  ssh_password       = "packer"
  ssh_wait_timeout   = "20m"
  vm_name            = "rocky-linux-template"
  guest_os_type      = "centos7-64"
  disk_size          = 20480
  memory             = 2048
  cpus               = 2
  shutdown_command   = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  sources = ["source.vmware-iso.rocky_linux"]

  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y vim"
    ]
  }
}
