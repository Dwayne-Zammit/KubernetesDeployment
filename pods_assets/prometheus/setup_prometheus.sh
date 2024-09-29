kubectl apply -f prometheus-config.yaml
kubectl  apply -f prometheus-service.yaml
kubectl apply -f prometheus-deployment.yaml

nohup kubectl port-forward service/prometheus-service 9090:80 > /home/ubuntu/port-forward-prometheus.log 2>&1 < /dev/null &
