#!/bin/sh

# Clone do Kubespray
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray

# Ajustes no diretório do Kubespray e cópia do arquivo de inventário
cp -rfp inventory/sample inventory/bexs
cp -rfp /home/vagrant/files/inventory.ini inventory/bexs/

# Atualização e instalação das dependências do Python
apk update
apk add python3 py3-pip
pip3 install --upgrade pip
pip3 install --upgrade setuptools
pip3 install -r requirements.txt
