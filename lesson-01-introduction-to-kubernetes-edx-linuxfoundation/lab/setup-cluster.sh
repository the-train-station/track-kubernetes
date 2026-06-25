#!/usr/bin/env bash
# setup-cluster.sh — Create a kind cluster for the Kubernetes lab exercises
set -euo pipefail

CLUSTER_NAME="k8s-lab"

# Check prerequisites
for cmd in kind kubectl; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' is required but not installed."
    echo "  kind:    https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    echo "  kubectl: https://kubernetes.io/docs/tasks/tools/"
    exit 1
  fi
done

# Create cluster if it doesn't already exist
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  echo "Cluster '${CLUSTER_NAME}' already exists. Skipping creation."
else
  echo "Creating kind cluster '${CLUSTER_NAME}'..."
  kind create cluster --name "${CLUSTER_NAME}" --wait 60s
fi

# Wait for all nodes to be Ready
echo "Waiting for nodes to become Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s

# Verify core components are running
echo "Waiting for kube-system pods to be ready..."
kubectl -n kube-system wait --for=condition=Ready pods --all --timeout=120s

echo ""
echo "Cluster '${CLUSTER_NAME}' is ready."
echo "Context: $(kubectl config current-context)"
kubectl get nodes
