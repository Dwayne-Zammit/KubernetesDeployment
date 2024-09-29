kubectl apply -f proemtheus-config.yaml
kubectl  apply -f prometheus-service.yaml
kubectl apply -f proemtheus-deployment.yaml

nohup kubectl port-forward service/prometheus-service 9090:80 > port-forward-prometheus.log 2>&1 < /dev/null &
