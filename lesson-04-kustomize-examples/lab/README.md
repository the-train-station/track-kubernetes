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

### 2. Build Dev Overlay

```bash
kubectl kustomize overlays/dev/
```

Note the differences: namespace, image tag, replica count, log level.

### 3. Build Prod Overlay

```bash
kubectl kustomize overlays/prod/
```

Note: resource limits added, higher cache TTL, warn-level logging.

### 4. Compare Overlays Side by Side

```bash
diff <(kubectl kustomize overlays/dev/) <(kubectl kustomize overlays/prod/)
```

This shows exactly what differs between environments.

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

### 6. Clean Up

```bash
kubectl delete -k overlays/dev/
kubectl delete -k overlays/prod/
```

## Key Concepts

- **Base** contains shared manifests that work in any environment
- **Overlays** patch the base for specific environments without modifying it
- **Images** transformer updates image tags without touching the deployment YAML
- **Replicas** transformer scales deployments per-environment
- **Patches** apply strategic merge or JSON patches for fine-grained control
