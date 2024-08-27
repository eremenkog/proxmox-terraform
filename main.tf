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