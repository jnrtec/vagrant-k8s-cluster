#!/bin/bash
# Adicione aqui os comandos para rodar exemplos de aplicativos no Kubernetes
# kubectl apply -f https://k8s.io/examples/application/deployment.yaml
# kubectl rollout status deployment/nginx-deployment
kubectl run nginx --image=nginx --restart=Never --port=80
