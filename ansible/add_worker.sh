#!/bin/sh

#nécessite ansible installé et configuré avec install_ansible.sh
#prend en paramètre une adresse IP

#crée fichier config pour connection
sudo printf "# Ansible variables
ansible_ssh_user: ubuntu
ansible_ssh_private_key_file: /home/ubuntu/.ssh/penguinkey.pem

# Custom variables
hostname: %s" "$1" > /etc/ansible/inventory/pre/host_vars/$1

#ajoute à la liste des hosts
sudo mv /etc/ansible/inventory/pre/hosts /etc/ansible/inventory/pre/hosts_tmp
sudo sed "0,/^$/{s/^$/$1\n&/}"  /etc/ansible/inventory/pre/hosts_tmp > /etc/ansible/inventory/pre/hosts
sudo rm /etc/ansible/inventory/pre/hosts_tmp

sudo printf "\n%s" $1 >> /etc/ansible/inventory/pre/hosts
