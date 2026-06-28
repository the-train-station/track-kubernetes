# Lab 01: Helm Chart Evaluation

Use this lab to evaluate a Helm chart before installing it in a shared cluster.

## Prerequisites

- Helm 3 installed
- `diff`, `grep`, and a shell
- Optional: a disposable Kubernetes cluster for a dry-run install

## Exercise Flow

### 1. Complete the Chart Checklist

Open `chart-evaluation-checklist.md` and score the candidate chart for maintenance, security, configurability, documentation, and operational readiness.

Expected observation: each unchecked item becomes either a documented risk, a follow-up question, or a reason to reject the chart.

### 2. Render the Chart

```bash
chmod +x helm-evaluate.sh
./helm-evaluate.sh
```

Expected observations:

- `rendered/default-rendered.yaml` exists.
- `rendered/custom-rendered.yaml` exists.
- `rendered/values-diff.patch` shows the impact of `values.yaml`.
- The summary prints line counts for both rendered manifests.

### 3. Review Rendered Manifests

```bash
grep -n "kind: Deployment" rendered/custom-rendered.yaml | head
grep -n "kind: Service" rendered/custom-rendered.yaml | head
grep -n "securityContext" rendered/custom-rendered.yaml | head
grep -n "resources:" rendered/custom-rendered.yaml | head
```

Expected observations:

- Workload and Service resources are visible before installation.
- Security context and resource settings are either present or listed as risks.
- Any cluster-scoped RBAC or CRD is identified before the chart is installed.

### 4. Optional Server-Side Validation

```bash
helm template ingress-nginx ingress-nginx/ingress-nginx -f values.yaml \
  | kubectl apply --dry-run=server -f -
```

Expected observation: the API server accepts the rendered objects, or returns actionable schema or admission errors to investigate before installation.

## Deliverable

Submit the completed checklist, the rendered-manifest diff, and a one-page decision memo with an adopt/defer/reject recommendation.
