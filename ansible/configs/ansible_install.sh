sudo su
dnf -y install ansible-core 
mv /etc/ansible/ansible.cfg /etc/ansible/ansible.cfg.org
ansible-config init --disabled > /etc/ansible/ansible.cfg 

sudo sed -i 's/;host_key_checking=True/host_key_checking=False/' /etc/ansible/ansible.cfg 

#vi /etc/ansible/hosts