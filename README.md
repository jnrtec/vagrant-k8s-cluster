## Pré-requisitos

Esse laboratório requer:

### Softwares:
* **Vagrant**: 2.2.7
* **Linux:** VirtualBox
* **Windows:** VirtualBox
* **openssh client**
* **Git Client**

### Hardware:
* **CPU:** 6
* **Memória:** 8GB
* **HD:** 120GB

>**Obs.:** O Disco é flexível, sendo possível diminuir alterando o Vagrantfile.

## Preparando a infraestrutura

1. Acesse o link abaixo para baixar o Vagrant:

   * [Vagrant Downloads](https://www.vagrantup.com/downloads.html)
   * [Vagrant 2.2.7 Releases](https://releases.hashicorp.com/vagrant/2.2.7/)

2. Faça o download do Vagrant para seu sistema operacional.

3. Realize a instalação:

   #### Debian-Based:
   ```bash
   dpkg -i <file.deb>
   ```

   #### RedHat-Based:
   ```bash
   rpm -ivh <file.rpm>
   ```

   #### Windows:
   * Clique no instalador.
   * Siga o assistente até finalizar a instalação.
   * Reinicie o computador.

## Download do Ubuntu

Para realizar o download da "box" do Ubuntu, execute o comando:

#### Linux:
```bash
$ vagrant box add ubuntu/focal64
$ vagrant plugin install scp-vagrant
```

#### Windows:
```powershell
PS> vagrant.exe box add ubuntu/focal64
PS> vagrant.exe plugin install scp-vagrant
```

>**Obs.:** Selecione o virtualizador VirtualBox.

>**Atenção:** Esse laboratório só funciona com o VirtualBox.

## Criando chaves SSH

Execute os comandos abaixo:

#### Linux:
```bash
$ ssh-keygen -f files/id_rsa
```

#### Windows:
```powershell
PS> ssh-keygen.exe -f files/id_rsa
```

## Subindo as Máquinas Virtuais

Para subir as máquinas virtuais, execute os comandos abaixo:

#### Linux:
```bash
$ vagrant up
```

#### Windows:
```powershell
PS> vagrant.exe up
```

## O Projeto

Esse projeto cria quatro máquinas virtuais:

* **controller**: 192.168.16.10
* **kubemaster01**: 192.168.16.20
* **node01**: 192.168.16.30
* **node02**: 192.168.16.40

>O endereço do load balancer é: **192.168.16.50**

### Controller

Essa máquina virtual é responsável por instalar e gerenciar o cluster Kubernetes. Ela possui os seguintes utilitários:

* Ansible
* Docker
* Helm Client
* Kubectl
* Docker Registry

Ela também é utilizada como um gerenciador de instalação. As configurações executadas por ela são:

* Instalação do cluster Kubernetes através do kubespray (Ansible).
* Instalação de um load balancer para o k8s (Ansible).
* Instalação do ingress controller (Helm).
* Instalação de um serviço de docker registry (Ansible).
* Armazenar imagens dos projetos (Docker Registry).

### Kubemaster01

Essa máquina virtual faz o papel de master do cluster Kubernetes. Ela faz a orquestração do cluster e armazena o banco de dados etcd.

### Node01 e Node02

Essas são as máquinas virtuais onde são executados nossos workloads. Fazem o papel de nó do cluster.

## Após a instalação

### Comandos úteis

Acessando o controlador:
```bash
vagrant ssh controller
```

Verificando o cluster k8s:
```bash
kubectl get nodes
```

O projeto sobe um serviço do nginx com o objetivo de testar se a instalação do cluster foi bem-sucedida. Para verificar, acesse o endereço:

http://nginx.192.168.16.50.nip.io/

Veja as configurações desse workload:
```bash
kubectl get all
kubectl get ingress
```

Abaixo o resultado esperado:
```bash
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
ingress-nginx   <none>   nginx.192.168.16.50.nip.io   192.168.16.50   80      6m7s
```

Se você chegou até aqui, é um bom sinal. Estamos prontos para utilizar nosso laboratório. :)

---
