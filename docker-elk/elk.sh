#!/bin/bash
sudo systemctl stop elastic-agent
sudo elastic-agent uninstall
sudo rm -rf /opt/Elastic/Agent
rm -rf elastik-agent-8.15.2-linux-x86_64
rm -rf elastik-agent-8.15.2-linux-x86_64.tar.gz
chmod +x setup/entrypoint.sh
docker-compose up setup
docker compose -f docker-compose.yml -f extensions/filebeat/filebeat-compose.yml up -d
docker compose -f docker-compose.yml -f extensions/fleet/fleet-compose.yml up -d

KIBANA_URL="http://0.0.0.0:5601"
KIBANA_USER="elastic"
KIBANA_PASSWORD="changeme"
FLEET_URL="http://0.0.0.0:8220"


POLICY_RESPONSE=$(curl -s -X POST "$KIBANA_URL/api/fleet/agent_policies" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -u $KIBANA_USER:$KIBANA_PASSWORD \
  -d '{
    "name": "Automated Agent Policy",
    "namespace": "default"
  }')


POLICY_ID=$(echo $POLICY_RESPONSE | jq -r '.item.id')


if [ "$POLICY_ID" == "null" ] || [ -z "$POLICY_ID" ]; then
  echo "Помилка при створенні Agent Policy."
  exit 1
else
  echo "Agent Policy створено з ID: $POLICY_ID"
fi


TOKEN_RESPONSE=$(curl -s -X POST "$KIBANA_URL/api/fleet/enrollment_api_keys" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -u $KIBANA_USER:$KIBANA_PASSWORD \
  -d "{
    \"policy_id\": \"$POLICY_ID\"
  }")


ENROLLMENT_TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.item.api_key')


if [ "$ENROLLMENT_TOKEN" == "null" ] || [ -z "$ENROLLMENT_TOKEN" ]; then
  echo "Помилка при отриманні enrollment token."
  exit 1
else
  echo "Enrollment token отримано: $ENROLLMENT_TOKEN"
fi


curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.15.2-linux-x86_64.tar.gz
tar xzvf elastic-agent-8.15.2-linux-x86_64.tar.gz
cd elastic-agent-8.15.2-linux-x86_64


sudo ./elastic-agent install --url=$FLEET_URL --enrollment-token=$ENROLLMENT_TOKEN --insecure

echo "Elastic Agent встановлено успішно."
cd ..
kubectl apply -f elastic-agent-standalone-kubernetes.yml
kubectl patch configmap coredns -n kube-system --type merge -p '{"data":{"Corefile":".:53 {\n    errors\n    health {\n       lameduck 5s\n    }\n    ready\n    kubernetes cluster.local in-addr.arpa ip6.arpa {\n       pods insecure\n       fallthrough in-addr.arpa ip6.arpa\n       ttl 30\n    }\n    prometheus :9153\n    forward . /etc/resolv.conf {\n       max_concurrent 1000\n    }\n    cache 30\n    loop\n    reload\n    loadbalance\n    rewrite name elasticsearch 192.168.0.103\n}  \n"}}'
kubectl patch configmap coredns -n kube-system --type merge -p '{"data":{"Corefile":".:53 {\n    errors\n    health {\n       lameduck 5s\n    }\n    ready\n    kubernetes cluster.local in-addr.arpa ip6.arpa {\n       pods insecure\n       fallthrough in-addr.arpa ip6.arpa\n       ttl 30\n    }\n    prometheus :9153\n    forward . /etc/resolv.conf {\n       max_concurrent 1000\n    }\n    cache 30\n    loop\n    reload\n    loadbalance\n    rewrite name elasticsearch 192.168.0.103\n    rewrite name k8s-worker-noble 192.168.0.102\n}  \n"}}'
kubectl -n kube-system rollout restart deployment coredns

pods=$(kubectl get pods -n kube-system -l app=elastic-agent -o jsonpath="{.items[*].metadata.name}")

if [ -z "$pods" ]; then
  echo "Elastic Agent pod not found in the kube-system namespace."
else
  # Видаляємо кожен знайдений pod
  for pod in $pods; do
    echo "Deleting Elastic Agent pod: $pod"
    kubectl delete pod "$pod" -n kube-system
  done
fi
