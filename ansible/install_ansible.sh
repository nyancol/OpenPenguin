#!/bin/sh

sudo apt-get update
sudo apt-get install software-properties-common

sudo apt-get install python-pip
sudo pip install docker-compose

sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible

cd /etc/ansible
sudo rm hosts
sudo touch hosts
sudo printf '358i\[slaves]\n10.11.53.39' hosts

sudo printf 'ssh_args = -F ssh.cfg
control_path = /.ssh/mux-%r@%h:%p' >> ansible.cfg

sudo printf '# Connexion directe avec le bastion.
# Pensez à adapter le User et le IdentityFile selon vos besoins.
Host bastion  
 Hostname 84.39.41.33
 User ubuntu
 IdentityFile /home/ubuntu/.ssh/penguinkey.pem

# Pour toutes les machines de la zone privée :
# Vous pouvez renseigner un range d’IPs ou une zone dns, exemple:
#    *.eu-west-1.compute.amazonaws.com
Host 192.168.47.*  
# Proxifier la connexion au travers du bastion.
 ProxyCommand ssh -F ssh.cfg -W %h:%p bastion
# A adapter à votre cas : le User et la clé pour les connexions aux machines privées.
 User ubuntu
 IdentityFile /home/ubuntu/.ssh/penguinkey.pem

# Directives de multiplexing SSH
Host *  
 ControlMaster   auto
 ControlPath     ~/.ssh/mux-%r@%h:%p
 ControlPersist  15m' > ssh.cfg