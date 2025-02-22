resource "proxmox_cloud_init_disk" "ci-consul01" {
  name     = "consul01"
  pve_node = "ns33672748"
  storage  = "local"

  meta_data = yamlencode({
    instance_id    = sha1("consul01")
    local-hostname = "consul01"
  })

  user_data = <<EOT
#cloud-config
package_update: true
package_upgrade: true
package_reboot_if_required: true
packages:
 - screen
 - htop
manage_etc_hosts: localhost
ssh_pwauth: True

EOT

  network_config = yamlencode({
    version = 1
    config = [{
      type = "physical"
      name = "ens18"
      subnets = [{
        type            = "static"
        address         = "192.168.69.11/24"
        gateway         = "192.168.69.1"
        dns_nameservers = ["192.168.69.1"]
      }]
    }]
  })
}

resource "proxmox_vm_qemu" "consul01" {
  name        = "consul01"
  desc        = "Consul Server"
  target_node = local.pm_node
  clone       = "tpl-ubuntu-2404"
  full_clone  = "true"
  bios        = "seabios"

  agent         = 1
  agent_timeout = 120
  skip_ipv6     = true

  os_type  = "cloud-init"
  cores    = 1
  sockets  = 1
  vcpus    = 0
  cpu      = "host"
  memory   = 1024
  scsihw   = "virtio-scsi-pci"
  bootdisk = "virtio0"
  boot     = "order=virtio0"

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:${proxmox_cloud_init_disk.ci-consul01.id}"
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          size    = 30
          storage = "local"
        }
      }
    }
  }


  network {
    model  = "virtio"
    bridge = "vmbr1"
  }
}
