#!/bin/bash
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
