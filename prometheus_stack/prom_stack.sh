kubectl create namespace monitoring
cd kubernetes-prometheus
kubectl create -f clusterRole.yaml
kubectl create -f config-map.yaml
kubectl create  -f prometheus-deployment.yaml 
sleep 30
kubectl get deployments --namespace=monitoring
kubectl create -f prometheus-service.yaml --namespace=monitoring

cd ..
kubectl apply -f kube-state-metrics-configs/
kubectl get deployments kube-state-metrics -n kube-system

cd kubernetes-node-exporter
kubectl create -f daemonset.yaml
kubectl get daemonset -n monitoring
kubectl create -f service.yaml
kubectl get endpoints -n monitoring 

cd ../kubernetes-grafana
kubectl create -f grafana-datasource-config.yaml
kubectl create -f deployment.yaml
kubectl create -f service.yaml

cd ../kubernetes-alert-manager
kubectl create -f AlertManagerConfigmap.yaml
kubectl create -f AlertTemplateConfigMap.yaml
kubectl create -f Deployment.yaml
kubectl create -f Service.yaml
