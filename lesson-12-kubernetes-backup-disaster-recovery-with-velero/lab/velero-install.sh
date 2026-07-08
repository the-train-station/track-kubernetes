#!/usr/bin/env bash
# velero-install.sh — Install Velero into the current kubectl context, backed by an S3 bucket
# Wires Velero to AWS S3 for cluster resource + volume snapshot backups
set -euo pipefail

BUCKET="${BUCKET:-<your-velero-bucket-name>}"
REGION="${REGION:-<your-aws-region>}"
CREDS_FILE="./credentials-velero"

# Check prerequisites
if ! command -v velero &>/dev/null; then
  echo "ERROR: 'velero' CLI is required but not installed."
  echo "  Install: https://velero.io/docs/main/basic-install/#install-the-cli"
  exit 1
fi

if ! command -v kubectl &>/dev/null; then
  echo "ERROR: 'kubectl' is required but not installed."
  exit 1
fi

if ! kubectl cluster-info &>/dev/null; then
  echo "ERROR: kubectl cannot reach a cluster. Check your current context with 'kubectl config current-context'."
  exit 1
fi

if [ ! -f "${CREDS_FILE}" ]; then
  echo "ERROR: ${CREDS_FILE} not found."
  echo "  Copy credentials-velero.example to ${CREDS_FILE} and fill in your AWS keys."
  exit 1
fi

if [ "${BUCKET}" = "<your-velero-bucket-name>" ]; then
  echo "ERROR: Set BUCKET to a real S3 bucket name before running this script."
  exit 1
fi

echo "Installing Velero into the current cluster context: $(kubectl config current-context)"
echo "  Bucket: ${BUCKET}"
echo "  Region: ${REGION}"
echo ""

velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.9.0 \
  --bucket "${BUCKET}" \
  --backup-location-config region="${REGION}" \
  --snapshot-location-config region="${REGION}" \
  --secret-file "${CREDS_FILE}"

echo ""
echo "=== Summary ==="
echo "Velero installed into the 'velero' namespace."
echo "Verify with: velero backup-location get"
echo "Next: apply lab/backup-schedule.yaml to enable scheduled backups."
