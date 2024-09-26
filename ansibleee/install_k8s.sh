sudo systemctl stop kubelet
sudo systemctl stop kube-apiserver
sudo systemctl stop kube-controller-manager
sudo systemctl stop kube-scheduler
sudo systemctl stop etcd
sudo rm /etc/kubernetes/manifests/kube-apiserver.yaml
sudo rm /etc/kubernetes/manifests/kube-controller-manager.yaml
sudo rm /etc/kubernetes/manifests/kube-scheduler.yaml
sudo rm /etc/kubernetes/manifests/etcd.yaml
sudo rm -rf /var/lib/etcd
sudo kubeadm reset

sudo hostnamectl set-hostname "k8s-master-noble"
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

sudo tee /etc/sysctl.d/kubernetes.conf <<EOT
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOT

sudo sysctl --system
ansible-playbook -i ../inventory.ini docker.yml --ask-pass --ask-become-pass
sudo apt update && sudo apt install containerd.io -y
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/k8s.gpg
echo 'deb [signed-by=/etc/apt/keyrings/k8s.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/k8s.list
sudo apt update
sudo apt install kubelet kubeadm kubectl -y
sudo kubeadm init --control-plane-endpoint=k8s-master-noble

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl get nodes
kubectl get pods -n kube-system


