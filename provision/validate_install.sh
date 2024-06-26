#!/bin/bash

# Verifique os nós do cluster
echo "Verificando nós do cluster..."
kubectl get nodes

# Verifique os componentes principais
echo "Verificando pods em todas as namespaces..."
kubectl get pods --all-namespaces

# Desplegar um aplicativo simples (Nginx)
echo "Criando deployment Nginx..."
kubectl create deployment nginx --image=nginx

echo "Expondo deployment Nginx como serviço NodePort..."
kubectl expose deployment nginx --port=80 --type=NodePort

# Verifique o deployment e o serviço
echo "Verificando deployments..."
kubectl get deployments

echo "Verificando serviços..."
kubectl get services

# Obtenha a URL do serviço Nginx
SERVICE_PORT=$(kubectl get service/nginx -o go-template='{{(index .spec.ports 0).nodePort}}')
NODE_IP=$(kubectl get nodes -o wide | awk 'NR==2 {print $6}')

echo "Acessando o serviço Nginx em http://$NODE_IP:$SERVICE_PORT"
curl http://$NODE_IP:$SERVICE_PORT
