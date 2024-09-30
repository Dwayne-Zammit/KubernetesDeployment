kubectl apply -f elk-namespace.yaml
kubectl apply -f elasticsearch-deployment.yaml
kubectl apply -f kibana-deployment.yaml
kubectl apply -f logstash-deployment.yaml
kubectl apply -f logstash-config.yaml

NAMESPACE="elk"  # Change this if your ELK stack is in a different namespace
# Forward Kibana port
nohup kubectl port-forward service/kibana 5601:5601 -n $NAMESPACE > /home/ubuntu/kibana-port-forward.log 2>&1 < /dev/null &
# Forward Elasticsearch port
nohup kubectl port-forward service/elasticsearch 9200:9200 -n $NAMESPACE > /home/ubuntu/elasticsearch-port-forward.log 2>&1 < /dev/null &
# Forward Logstash port
nohup kubectl port-forward service/logstash 5044:5044 -n $NAMESPACE > /home/ubuntu/logstash-port-forward.log 2>&1 < /dev/null &