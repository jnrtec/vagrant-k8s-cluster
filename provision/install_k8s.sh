#!/bin/sh

export ANSIBLE_HOST_KEY_CHECKING=False

# Configuração de permissões para a chave privada
chmod 700 /home/vagrant/files/id_rsa

cd kubespray
ansible-playbook --private-key /home/vagrant/files/id_rsa -i inventory/bexs/inventory.ini cluster.yml
