kubectl apply -f flask-service.yaml
kubectl apply -f flask-deployment.yaml

nohup kubectl port-forward service/flask-service 5000:5000 > /home/ubuntu/flask-port-forward.log 2>&1 < /dev/null &