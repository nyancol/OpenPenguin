#!/bin/sh

#=============INSTALLATION ANSIBLE=============
sudo apt-get update
sudo apt-get install software-properties-common

sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible

#=============CONFIGURATION ANSIBLE=============
ip=$(ifconfig ens3 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

sudo printf '# Connexion directe avec le bastion.
Host bastion  
 Hostname ' + $ip + '
 User ubuntu
 IdentityFile /home/ubuntu/.ssh/penguinkey.pem

# Pour toutes les machines de la zone privée :
# Vous pouvez renseigner un range d’IPs ou une zone dns, exemple:
#    *.eu-west-1.compute.amazonaws.com
Host 10.9.8.*
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

git clone https://github.com/nyancol/OpenPenguin.git
cd OpenPenguin/ansible
yes | sudo cp -a conf/ /etc/ansible/
sudo cp -R inventory /etc/ansible/
sudo cp -R playbooks /etc/ansible/
sudo cp -R roles /etc/ansible/

#=============CREATE CLUSTER=============
sudo rm -rf inventory/pre/host_vars/*
sudo rm inventory/pre/hosts
sudo printf "[docker_cluster]
%s

[docker_cluster_primary]
%s

[docker_cluster_replicas]" "$ip" "$ip" > inventory/pre/hosts

#faire appel à add_worker pour ajouter une machine
#exemple : sudo ./add_worker <@IP>