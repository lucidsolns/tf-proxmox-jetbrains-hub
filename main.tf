terraform {
  required_version = "~> 1.5.0"
}
/*
    Jetbrains Hub (deployed as a container on Flatcar Linux)

    Before creating the VM, the following ZFS based directory is used for Hub data:
      zfs create -o quota=10G -o mountpoint=/droplet/data/jetbrains-hub-data droplet/140-ochre-jetbrains-hub-data

    The data directory is put into the Flatcar Linux VM using plan9fs, then it
    is mounted using 4 paths into the hub docker container.
*/
module "ochre" {
  source        = "lucidsolns/proxmox/vm"
  version       = ">= 0.0.13"
  vm_id         = 140
  name          = "ochre.lucidsolutions.co.nz"
  description   = <<-EOT
      Jetbrains Hub running as a container on Flatcar Linux with plan9fs for data/logs/conf/backup
  EOT
  startup       = "order=80"
  tags          = ["flatcar", "jetbrains", "hub", "development"]
  pm_api_url    = var.pm_api_url
  target_node   = var.target_node
  pm_user       = var.pm_user
  pm_password   = var.pm_password
  template_name = "flatcar-production-qemu-3602.2.1"
  butane_conf   = "${path.module}/jetbrains-hub.bu.tftpl"
  memory        = 4096
  networks      = [{ bridge = var.bridge, tag = 121 }]
  plan9fs       = [
    {
      dirid = "/droplet/data/jetbrains-hub-data"
      tag   = "hub-data"
    }
  ]
}

