#!/bin/sh

cd configure-controller

# Instalação do Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Instalação das dependências do Ansible
apk update
apk add py3-pip
pip3 install -r requirements.txt

# Instalação das coleções do Ansible
ansible-galaxy collection install -r requirements.yml

# Execução do playbook do Ansible
ansible-playbook -i inventory.ini configure.yml
