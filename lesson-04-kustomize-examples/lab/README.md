# Lab 04: Kustomize Overlays

Learn how Kustomize enables environment-specific configuration without duplicating manifests.

## Structure

```
lab/
├── base/                  # Shared resources (deployment, service, configmap)
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
└── overlays/
    ├── dev/               # Dev: 1 replica, debug logging, alpine image
    │   └── kustomization.yaml
    └── prod/              # Prod: 3 replicas, warn logging, resource limits
        └── kustomization.yaml
```

## Exercises

### 1. Build and Inspect Base

```bash
kubectl kustomize base/
```

Review the output. This is what gets deployed without any overlay.

Expected observations: the rendered YAML includes one Deployment, one Service, and one ConfigMap with the shared `managed-by: kustomize` label.

### 2. Build Dev Overlay

```bash
kubectl kustomize overlays/dev/
```

Note the differences: namespace, image tag, replica count, log level.

Expected observations: resources render into the `dev` namespace, nginx uses the alpine tag, the Deployment has one replica, and `LOG_LEVEL` is `debug`.

### 3. Build Prod Overlay

```bash
kubectl kustomize overlays/prod/
```

Note: resource limits added, higher cache TTL, warn-level logging.

Expected observations: resources render into the `prod` namespace, the Deployment has three replicas, resource requests and limits are present, and `LOG_LEVEL` is `warn`.

### 4. Compare Overlays Side by Side

```bash
diff <(kubectl kustomize overlays/dev/) <(kubectl kustomize overlays/prod/)
```

This shows exactly what differs between environments.

Expected observation: the diff is limited to intentional environment differences such as namespace, labels, image tag, replica count, ConfigMap values, and prod resource limits.

### 5. Apply to a Cluster

```bash
# Create namespaces first
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -

# Deploy dev
kubectl apply -k overlays/dev/

# Deploy prod
kubectl apply -k overlays/prod/

# Verify both environments
kubectl get all -n dev
kubectl get all -n prod
```

Expected observations: both namespaces contain a Service and Deployment, dev has one Ready Pod, and prod has three Ready Pods.

### 6. Clean Up

```bash
kubectl delete -k overlays/dev/
kubectl delete -k overlays/prod/
```

Expected observation: `kubectl get all -n dev` and `kubectl get all -n prod` no longer show the webapp resources after cleanup.

## Key Concepts

- **Base** contains shared manifests that work in any environment
- **Overlays** patch the base for specific environments without modifying it
- **Images** transformer updates image tags without touching the deployment YAML
- **Replicas** transformer scales deployments per-environment
- **Patches** apply strategic merge or JSON patches for fine-grained control

## Deliverable

Submit a rendered-manifest review with the base, dev, and prod outputs plus a short explanation of every intentional environment difference.
