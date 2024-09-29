# sudo apt-get update
# sudo apt-get install -y apt-transport-https

# # docker
# sudo apt -y install docker.io
# sudo systemctl start docker
# sudo systemctl enable docker

# sudo groupadd docker
# sudo usermod -aG docker $USER

# # change docker permissions
# sudo chmod 666 /var/run/docker.sock

# sudo apt-get -y install curl
# sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

# sudo chmod 777 /etc/apt/sources.list.d/

# # minikube
# curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
# sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

# # set docker default driver
# minikube config set driver docker
# # minikube start --driver=docker

# # kubectl
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# chmod 775 kubectl
# sudo mv kubectl /usr/local/bin


# sudo apt-get update

# echo "check if we need to install pip"
# sudo apt -y install python3-pip
# sudo apt -y install python3-venv

# # kinds
# curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
# chmod +x ./kind
# sudo mv ./kind /usr/local/bin/kind
# kind create cluster

# minikube start --driver=docker

