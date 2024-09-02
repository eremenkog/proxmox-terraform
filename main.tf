resource "proxmox_vm_qemu" "ansible-vm" {
  name = var.ansible_vm.name
 
  agent = 1
  bootdisk = "scsi0"
  clone      = var.template_names.centos9
  full_clone = true
  os_type  = "cloud-init"
  target_node = "pve"
  scsihw   = "virtio-scsi-single"
 
  cores = 2
  memory = 1024
 
  disks {
    ide {
	  ide2 {
	    cloudinit {
		  storage = "local-lvm"
		          }
		    }
		}	
     scsi {
       scsi0 {
	     disk {
	     size = "10G"
         storage = "local-lvm"
              }
             }
	      }
	    }

  sshkeys = file(var.ansible_vm.ssh_pub_key)

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}

resource "proxmox_vm_qemu" "k8s_ctrl" {
  name = var.k8s_ctrl.name
 
  agent = 1
  bootdisk = "scsi0"
  clone      = var.template_names.centos9
  full_clone = true
  os_type  = "cloud-init"
  target_node = "pve"
  scsihw   = "virtio-scsi-single"
 
  cores = 2
  memory = 2048
 
  disks {
    ide {
      ide2 {
        cloudinit {
	  storage = "local-lvm"
		  }
            }
	}	
     scsi {
       scsi0 {
         disk {
	   size = "10G"
           storage = "local-lvm"
              }
             }
	   }
	 }

  sshkeys = file(var.k8s_ctrl.ssh_pub_key)

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}

resource "proxmox_vm_qemu" "k8s_worker" {
  name = "k8s-wrk-${count.index + 1}"
 
  agent = 1
  bootdisk = "scsi0"
  clone      = var.template_names.centos9
  count = 2
  full_clone = true
  os_type  = "cloud-init"
  target_node = "pve"
  scsihw   = "virtio-scsi-single"
 
  cores = 2
  memory = 1024
 
  disks {
    ide {
      ide2 {
        cloudinit {
	  storage = "local-lvm"
		  }
            }
	}	
     scsi {
       scsi0 {
         disk {
	   size = "10G"
           storage = "local-lvm"
              }
             }
	   }
	 }

  sshkeys = file(var.k8s_ctrl.ssh_pub_key)

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}