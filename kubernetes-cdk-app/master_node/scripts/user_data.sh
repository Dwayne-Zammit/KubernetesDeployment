echo "master node"
sudo apt update -y && sudo apt install docker.io -y
sudo systemctl enable docker
sudo systemctl start docker
sudo docker --version
sudo hostnamectl set-hostname controlplane

sudo apt-get update
sudo apt install socat
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet
sudo kubeadm init
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo systemctl restart kubelet
# Reapply kube-proxy addon
sudo kubeadm init phase addon kube-proxy
kubectl get daemonset kube-proxy -n kube-system
curl -o /home/ubuntu/calico.yaml https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml
sudo chmod 777 /home/ubuntu/calico.yaml
kubectl apply -f /home/ubuntu/calico.yaml
kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule-
sudo systemctl stop apparmor
sudo systemctl disable apparmor
bash
reboot