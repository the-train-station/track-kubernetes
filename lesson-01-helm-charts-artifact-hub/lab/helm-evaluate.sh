#!/usr/bin/env bash
# helm-evaluate.sh — Render a Helm chart with default and custom values, then diff
# Helps understand what a chart actually deploys and how overrides change it
set -euo pipefail

CHART_REPO="ingress-nginx"
CHART_NAME="ingress-nginx/ingress-nginx"
RELEASE_NAME="ingress-nginx"
OUTPUT_DIR="./rendered"
VALUES_FILE="./values.yaml"

# Check prerequisites
if ! command -v helm &>/dev/null; then
  echo "ERROR: 'helm' is required but not installed."
  echo "  Install: https://helm.sh/docs/intro/install/"
  exit 1
fi

if ! command -v diff &>/dev/null; then
  echo "ERROR: 'diff' is required but not found."
  exit 1
fi

# Add the chart repo if not already added
echo "Adding Helm repo '${CHART_REPO}'..."
helm repo add "${CHART_REPO}" https://kubernetes.github.io/ingress-nginx 2>/dev/null || true
helm repo update

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Render with default values
echo ""
echo "Rendering chart with DEFAULT values..."
helm template "${RELEASE_NAME}" "${CHART_NAME}" \
  > "${OUTPUT_DIR}/default-rendered.yaml"
echo "  Saved to: ${OUTPUT_DIR}/default-rendered.yaml"
echo "  Lines: $(wc -l < "${OUTPUT_DIR}/default-rendered.yaml")"

# Render with custom overrides
echo ""
echo "Rendering chart with CUSTOM values (${VALUES_FILE})..."
helm template "${RELEASE_NAME}" "${CHART_NAME}" \
  -f "${VALUES_FILE}" \
  > "${OUTPUT_DIR}/custom-rendered.yaml"
echo "  Saved to: ${OUTPUT_DIR}/custom-rendered.yaml"
echo "  Lines: $(wc -l < "${OUTPUT_DIR}/custom-rendered.yaml")"

# Generate diff
echo ""
echo "Generating diff..."
DIFF_FILE="${OUTPUT_DIR}/values-diff.patch"
diff -u "${OUTPUT_DIR}/default-rendered.yaml" "${OUTPUT_DIR}/custom-rendered.yaml" \
  > "${DIFF_FILE}" 2>&1 || true

DIFF_LINES=$(wc -l < "${DIFF_FILE}")
echo "  Diff saved to: ${DIFF_FILE}"
echo "  Changed lines: ${DIFF_LINES}"

# Summary
echo ""
echo "=== Summary ==="
echo "Default render: ${OUTPUT_DIR}/default-rendered.yaml"
echo "Custom render:  ${OUTPUT_DIR}/custom-rendered.yaml"
echo "Diff:           ${DIFF_FILE}"
echo ""
echo "Review the diff to understand exactly what your value overrides change."
echo "Tip: Look for resource limits, replica counts, and disabled components."
