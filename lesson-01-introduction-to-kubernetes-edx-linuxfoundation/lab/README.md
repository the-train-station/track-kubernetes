# Lab 01: Introduction to Kubernetes

Hands-on exercises covering core Kubernetes concepts: Deployments, Services, scaling, and rolling updates.

## Prerequisites

- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed

## Exercise Flow

### 1. Create the Cluster

```bash
./setup-cluster.sh
```

### 2. Deploy nginx (3 replicas)

```bash
kubectl apply -f 01-deploy-nginx.yaml
kubectl get pods -l app=nginx
kubectl describe deployment nginx
```

### 3. Expose with a Service

```bash
kubectl apply -f 02-service.yaml
kubectl get svc nginx
# Test connectivity from within the cluster:
kubectl run curl --rm -it --image=curlimages/curl -- curl http://nginx
```

### 4. Scale to 5 Replicas

```bash
kubectl apply -f 03-scale.yaml
kubectl get pods -l app=nginx -w
```

### 5. Rolling Update to nginx:1.25

```bash
kubectl apply -f 04-rolling-update.yaml
kubectl rollout status deployment/nginx
kubectl describe deployment nginx | grep Image
```

### 6. Rollback (optional)

```bash
kubectl rollout undo deployment/nginx
kubectl rollout status deployment/nginx
```

### 7. Teardown

```bash
./teardown.sh
```

## Key Concepts Practiced

- Creating and inspecting Deployments
- Service discovery with ClusterIP
- Declarative scaling
- Rolling updates and rollbacks
