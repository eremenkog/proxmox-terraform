#!/bin/bash

declare -A distribs_versions
distribs_versions["Debian"]="Bookworm (12),Trixie (13),Sid (unstable)"
distribs_versions["Ubuntu"]="20.04 LTS (Focal Fossa),22.04 LTS (Jammy Jellyfish),23.10 (Manic Minotaur)"
distribs_versions["Fedora"]="Fedora 37,Fedora 38"
distribs_versions["Rocky Linux"]="Rocky 8 latest,Rocky 9 latest"
distribs_versions["Alpine Linux"]="Alpine 3.19.1"
distribs_versions["CentOS"]="CentOS 7, CentOS 8"

function list_array() {
  arr=("$@")
  for i in "${!arr[@]}"; do
    echo "$i. ${arr[$i]}"
  done
}

function download_image() {
    url=$1
    disk_name=$2
    
    wget "$url"
    if [[ "$disk_name" == *.xz ]]; then
        xz -d -v "$disk_name"
        disk_name="${disk_name%.xz}"
    fi
    
    echo $disk_name
}

function create_template() {
    echo "Suggest VM name:"
    read vm_name
    
    echo "Suggest VM id:"
    read vm_id
    
    echo "Select distribution:"
    distros=("${!distribs_versions[@]}")  # Получаем массив ключей ассоциативного массива
    list_array "${distros[@]}"
    read choice_distr
    selected_distr="${distros[$choice_distr]}"
    echo "Selected:" $selected_distr
    
    IFS=',' read -r -a versions <<< "${distribs_versions[$selected_distr]}"
    echo "Select release:"
    list_array "${versions[@]}"
    read distr_ver_choice
    distr_ver="${versions[$distr_ver_choice]}"
    
    distr_ver=$(echo "$distr_ver" | xargs)
    echo "Distr_ver:" $distr_ver
    
    case "$distr_ver" in
        "Bookworm (12)") disk=$(download_image "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2" "debian-12-genericcloud-amd64.qcow2");;
        "Trixie (13)") disk=$(download_image "https://cloud.debian.org/images/cloud/trixie/daily/latest/debian-13-genericcloud-amd64-daily.qcow2" "debian-13-genericcloud-amd64-daily.qcow2");;
        "Sid (unstable)") disk=$(download_image "https://cloud.debian.org/images/cloud/sid/daily/latest/debian-sid-genericcloud-amd64-daily.qcow2" "debian-sid-genericcloud-amd64-daily.qcow2");;
        "20.04 LTS (Focal Fossa)") disk=$(download_image "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img" "ubuntu-20.04-server-cloudimg-amd64.img");;
        "22.04 LTS (Jammy Jellyfish)") disk=$(download_image "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img" "ubuntu-22.04-server-cloudimg-amd64.img");;
        "23.10 (Manic Minotaur)") disk=$(download_image "https://cloud-images.ubuntu.com/releases/23.10/release/ubuntu-23.10-server-cloudimg-amd64.img" "ubuntu-23.10-server-cloudimg-amd64.img");;
        "Fedora 37") disk=$(download_image "https://download.fedoraproject.org/pub/fedora/linux/releases/37/Cloud/x86_64/images/Fedora-Cloud-Base-37-1.7.x86_64.raw.xz" "Fedora-Cloud-Base-37-1.7.x86_64.raw.xz");;
        "Fedora 38") disk=$(download_image "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/x86_64/images/Fedora-Cloud-Base-38-1.6.x86_64.raw.xz" "Fedora-Cloud-Base-38-1.6.x86_64.raw.xz");;
        "Rocky 8 latest") disk=$(download_image "http://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud.latest.x86_64.qcow2" "Rocky-8-GenericCloud.latest.x86_64.qcow2");;
        "Rocky 9 latest") disk=$(download_image "http://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2" "Rocky-9-GenericCloud.latest.x86_64.qcow2");;
        "Alpine 3.19.1") disk=$(download_image "https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/cloud/nocloud_alpine-3.19.1-x86_64-bios-cloudinit-r0.qcow2" "nocloud_alpine-3.19.1-x86_64-bios-cloudinit-r0.qcow2");;
		"CentOS 7") disk=$(download_image "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2c" "CentOS-7-x86_64-GenericCloud.qcow2c");;
		"CentOS 8") disk=$(download_image "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2" "CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2");;
        *) echo "$distr_ver not found"; exit;;
    esac

    echo "Creating template $vm_name ($vm_id)"
	
	qm create $vm_id --name $vm_name --ostype l26 
    qm set $vm_id --net0 virtio,bridge=vmbr0
    qm set $vm_id --serial0 socket --vga serial0
    #If you are in a cluster, you might need to change cpu type
    qm set $vm_id --memory 1024 --cores 4 --cpu host
    
	storages_string=$(pvesm status | awk '{print $1}' | tail -n +2)
	mapfile -t storages_array <<<"$storages_string"
	echo "Select storage:"
	list_array "${storages_array[@]}"
	read choise_storage
	storage=${storages_array[choise_storage]}
	echo "Storage selected:" $storage

	qm set $vm_id --scsi0 ${storage}:0,import-from="$(pwd)/$disk",discard=on
    qm set $vm_id --boot order=scsi0 --scsihw virtio-scsi-single
    qm set $vm_id --agent enabled=1,fstrim_cloned_disks=1
    qm set $vm_id --ide2 ${storage}:cloudinit
    
	qm set $vm_id --ipconfig0 "ip6=auto,ip=dhcp"
	#Resize the disk to 10G, a reasonable minimum. You can expand it more later.
    qm disk resize $vm_id scsi0 10G

	# Optional!
	echo "Import the ssh keyfile? (yes/no)"
	read ssh_choise
	case $ssh_choise in
	"yes"|"Yes"|"y")
	echo "Provide a path for ssh keyfile (leave blank to use /etc/pve/priv/authorized_keys)"
	read ssh_path
	if [ -z "$ssh_path" ]
	then
      qm set $vm_id --sshkeys "/etc/pve/priv/authorized_keys"
	else
      qm set $vm_id --sshkeys $ssh_path
	fi
	;;
	"no"|"No"|"n")
	;;
	esac
	
	#Add the user
	echo "Suggest a username for ciuser:"
	read username
    qm set $vm_id --ciuser ${username}
	
	# Optional!
	echo "Create password for ciuser? (yes/no)":
	read password_choise

	case $password_choise in
	"yes"|"Yes"|"y")
	echo "Suggest a password:"
	read -s input_password
	qm set $vm_id --cipassword $input_password
	;;
	"no"|"No"|"n")
	;;
	esac

    qm template $vm_id
    rm $disk
}

create_template