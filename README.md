# vagrant-kubespray-k8s-cluster

## Requisitos Prévios

--------

Este laboratório requer os seguintes itens:

Software:
* **Vagrant**: Versão 2.2.7
* **Sistema Operacional Linux**: VirtualBox
* **Sistema Operacional Windows**: VirtualBox
* **Cliente openssh**
* **Cliente Git**

Hardware:
* **Processador (CPU)**: Mínimo 6 núcleos
* **Memória RAM**: Mínimo 8GB
* **Espaço em Disco**: Mínimo 120GB

> **Nota:** O espaço em disco é ajustável, podendo ser reduzido modificando o arquivo Vagrantfile.

## Preparação da Infraestrutura

---------

1. Acesse um dos links abaixo para baixar o Vagrant:

* https://www.vagrantup.com/downloads.html

* https://releases.hashicorp.com/vagrant/2.2.7/

2. Faça o download do Vagrant para o seu sistema operacional.
3. Realize a instalação seguindo as instruções abaixo:

* Para sistemas baseados em Debian:
  * Execute o comando: `dpkg -i <arquivo.deb>`
* Para sistemas baseados em RedHat:
  * Execute o comando: `rpm -ivh <arquivo.rpm>`
* Para sistemas Windows:
  * Execute o instalador e siga as instruções até concluir a instalação.
  * Reinicie o computador, se necessário.

## Download do CentOS 7

------------

Para baixar a imagem "box" do CentOS 7, utilize o seguinte comando:

#### No Linux
```bash
$ vagrant box add centos/7
$ vagrant plugin install scp-vagrant
```

#### No Windows
```powershell
PS> vagrant.exe box add centos/7
PS> vagrant.exe plugin install scp-vagrant
```
> **Observação:** *Certifique-se de selecionar o virtualizador VirtualBox durante o processo.*

> **Atenção:** Este laboratório requer o uso do VirtualBox.

## Geração de Chaves SSH

Execute os comandos abaixo para gerar as chaves SSH necessárias:

#### No Linux

```
$ ssh-keygen -f files/id_rsa
```

#### No Windows
```powershell
PS> ssh-keygen.exe -f files/id_rsa
```

#### Inicialização das Máquinas Virtuais

#### No Linux
```bash
$ vagrant up
```

#### No Windows
```powershell
PS> vagrant.exe up
```


## O Projeto

Este projeto consiste em quatro máquinas virtuais:

* Controlador **[172.25.10.10]**
* Kubemaster01 **[172.25.10.20]**
* Node01 **[172.25.10.30]**
* Node02 **[172.5.10.40]**

>O endereço do balanceador de carga é: **[172.25.10.50]**

#### Controlador

Esta máquina virtual é responsável pela instalação e gestão do cluster Kubernetes. Ela inclui os seguintes utilitários:

* Ansible
* Docker
* Cliente Helm
* Kubectl
* Registro Docker

Além disso, ela atua como um gerenciador de instalação, realizando as seguintes configurações:

* Instalação do cluster Kubernetes via Kubespray. **(Ansible)**
* Implementação de um balanceador de carga para o Kubernetes. **(Ansible)**
* Instalação do controlador de ingresso. **(Helm)**
* Configuração de um serviço de registro Docker. **(Ansible)**
* Armazenamento de imagens de projetos. **(Registro Docker)**

#### Kubemaster01

Esta máquina virtual desempenha o papel de nó mestre do cluster Kubernetes. Ela orquestra o cluster e armazena o banco de dados etcd.

#### Node01 e Node02

Essas máquinas virtuais executam nossos workloads, atuando como nós do cluster.

## Após a Instalação

#### Comandos Úteis:

Para acessar o controlador:
```
vagrant ssh controller
```

Para verificar o cluster Kubernetes:
```
kubectl get nodes
```

O projeto inicia um serviço nginx para testar a instalação do cluster. Para verificar, acesse o seguinte endereço:

http://nginx.172.25.10.50.nip.io/

Veja as configurações deste workload:

```
kubectl get all
kubectl get ingress
```
Abaixo está o resultado esperado:
```
[vagrant@controller ~]$ kubectl get all
NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-6799fc88d8-b7r96   1/1     Running   0          5m57s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.233.0.1     <none>        443/TCP   13m
service/nginx        ClusterIP   10.233.38.25   <none>        80/TCP    5m56s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   1/1     1            1           5m57s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-6799fc88d8   1         1         1       5m57s
[vagrant@controller ~]$ kubectl get ingress
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
NAME            CLASS    HOSTS                       ADDRESS        PORTS   AGE
ingress-nginx   <none>   nginx.172.25.10.50.nip.io   172.25.10.50   80      6m7s
```
Se você alcançou este ponto, é um bom sinal. O laboratório está pronto para ser utilizado. :)
