#!/usr/bin/env bash
# teardown.sh — Remove lab resources and optionally delete the kind cluster
set -euo pipefail

CLUSTER_NAME="k8s-lab"

echo "Deleting lab resources..."
kubectl delete -f 02-service.yaml --ignore-not-found
kubectl delete -f 01-deploy-nginx.yaml --ignore-not-found
echo "Resources deleted."

echo ""
read -rp "Delete the kind cluster '${CLUSTER_NAME}'? [y/N]: " answer
if [[ "${answer,,}" == "y" ]]; then
  kind delete cluster --name "${CLUSTER_NAME}"
  echo "Cluster '${CLUSTER_NAME}' deleted."
else
  echo "Cluster kept. Delete later with: kind delete cluster --name ${CLUSTER_NAME}"
fi
