# Ansible

## Prérequis

* Python sur toutes les machines (idéalement 2.7)
* Machines sur le même sous-réseau *10.9.8.**
* La clé ssh *penguinkey.pm* dans le repertoire */home/ubuntu/.ssh* du bastion pour automatiser les connections

## Installation

Se connecter au bastion et lancer le script *install_ansible* :
```sh
sudo ./install_ansible.sh
```
Ce script va installer et configurer ansible et docker sur la machine courante.
Le bastion sera le maître du cluster ainsi créé.

### Ajouter une machine

Se connecter au bastion et lancer le script *add_worker* :
```sh
sudo ./add_worker <@IP du worker>
```
Ce script va ajouter la machine à la configuration du cluster docker.
**Important:** Cet ajout n'est pas dynamique. Il est nécessaire de réinitialiser le cluster pour ajouter la machine, cf. *Déployer le cluster*.

### Déployer le cluster

Se connecter au bastion et lancer le play *deploy_docker_cluster*
```sh
sudo ansible-playbooks -i inventory/pre/hosts playboks/deploy_docker_cluster.yml
```
Ce script va installer docker et initialiser le swarm cluster sur les différentes machines.

### Informations

Quelques informations utiles :
* la liste des machines du cluster est visible dans *inventory/pre/hosts*
* la liste des plays ansible est visible dans *playbooks/*

## Déployer l'application

Se connecter au bastion et exécuter le play *deploy_app*, à condition que les étapes d'installation soit validées :
```sh
sudo ansible-playbooks -i inventory/pre/hosts playboks/deploy_app.yml
```
Ce script va télécharger l'application et exécuter le docker-compose. 
Si le swarm cluster docker fonctionne sans erreurs, les conteneurs seront automatiquement déployés sur les différentes machines et connectés entre eux. 