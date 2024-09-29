kubectl apply -f mongodb-pv.yaml
kubectl apply -f mongodb-pvc.yaml
kubectl apply -f mongodb-deployment.yaml
kubectl apply -f mongodb-nodeport-svc.yaml
kubectl apply -f mongodb-secrets.yaml

nohup kubectl port-forward service/mongo 27017:27017 > /home/ubuntu/mongo-port-forward.log 2>&1 < /dev/null &