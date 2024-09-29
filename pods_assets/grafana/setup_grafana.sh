kubectl apply -f grafana-config.yaml
kubectl  apply -f grafana-service.yaml
kubectl apply -f grafana-deployment.yaml

nohup kubectl port-forward service/grafana 3000:3000 > /home/ubuntu/port-forward-grafana.log 2>&1 < /dev/null &
