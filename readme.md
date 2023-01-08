# Kubernetes cluster with kubeadm

## Installing docker (all nodes)

    sudo apt-get update && sudo apt-get install docker.io -y

## Forwarding IPv4 and letting iptables see bridged traffic (all nodes)

    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
    overlay
    br_netfilter
    EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter

    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-iptables  = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    net.ipv4.ip_forward                 = 1
    EOF

    sudo sysctl --system

## Verify (all nodes)


    lsmod | grep br_netfilter
    lsmod | grep overlay

    sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

## cri-dockerd installation (All nodes)


    git clone https://github.com/Mirantis/cri-dockerd.git
    sudo wget https://storage.googleapis.com/golang/getgo/installer_linux
    sudo chmod +x ./installer_linux
    ./installer_linux   
    source ~/.bash_profile
    cd cri-dockerd
    mkdir bin
    go build -o bin/cri-dockerd
    mkdir -p /usr/local/bin
    sudo install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
    sudo cp -a packaging/systemd/* /etc/systemd/system
    sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
    sudo systemctl daemon-reload
    sudo systemctl enable cri-docker.service
    sudo systemctl enable --now cri-docker.socket
    cd ..


## Installing kubeadm,kubelet,kubectl (all nodes)

    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl
    sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl



## Initialize cluster (Do not run on worker node)


    sudo kubeadm init --apiserver-advertise-address=172.16.10.247 --pod-network-cidr 10.244.0.0/16 --cri-socket unix:///var/run/cri-dockerd.sock

## output


Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

    export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/


## CNI (Do not run on worker node)

    kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml



## The command below depends on the token generated by the controlplane which is output after kubeadm installations (run on worker node)

    sudo kubeadm join 172.16.10.247:6443 --token bdny2b.uhd85s8h0uuqq0lh \
	    --discovery-token-ca-cert-hash sha256:2efd34d584de448ed5a614904a5f38c91b9913a757b679d92e0857676f69233b \
	    --cir-socket unix:///var/run/cri-dockerd.sock
