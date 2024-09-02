variable "template_names" {
  default = {
  centos7 = "CentOS7-tmpl"
  centos8 = "CentOS8-tmpl"
  centos9 = "CentOS9-tmpl"
            }
}

variable "ansible_vm" {
  default = {
  name = "ansible"
  user = "legion"
  ip = "192.168.192.158"
  subnet = "/24"
  gw = "192.168.192.2"
             }
}

variable "k8s_ctrl" {
  default = {
  name = "k8s-ctrl"
  ip = "192.168.192.159"
  subnet = "/24"
  gw = "192.168.192.2"
            }
}

variable "k8s_worker" {
  type = object({
    name   = string
    ip     = list(string)
    subnet = string
    gw     = string
  })
  
  default = {
    name = "k8s_wrk"
    ip = ["192.168.192.100", "192.168.192.101"]
    subnet = "/24"
    gw = "192.168.192.2"
            }
}