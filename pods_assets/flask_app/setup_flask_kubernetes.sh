docker build -t flask-mongo-app:latest .
docker run -d -p 5001:5000 --restart=always --name registry registry:2
docker tag flask-mongo-app:latest localhost:5001/flask-mongo-app:latest
docker push localhost:5001/flask-mongo-app:latest
kubectl apply -f flask-service.yaml
kubectl apply -f flask-deployment.yaml

nohup kubectl port-forward service/flask-service 5000:5000 > port-forward.log 2>&1 < /dev/null &