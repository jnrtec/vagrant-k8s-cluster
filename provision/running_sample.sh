#!/bin/sh

export KUBECONFIG=/home/vagrant/.kube/config

# Criação de deployment e serviço no Kubernetes
kubectl create deployment --image=nginx nginx
kubectl expose deployment nginx --port=80 --target-port=80

# Aplicação do ingress no Kubernetes
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-nginx
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: nginx.192.168.15.50.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

# Reinício dos pods do MetalLB
kubectl -n metallb-system delete pod --all
