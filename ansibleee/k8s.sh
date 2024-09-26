ansible-playbook -i ../inventory.ini kubernetes.yml --ask-pass --ask-become-pass
kubectl rollout restart daemonset kube-proxy -n kube-system
kubectl get pods --all-namespaces
apt update
