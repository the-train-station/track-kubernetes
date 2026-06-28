# Lab 01: Introduction to Kubernetes

Hands-on exercises covering core Kubernetes concepts: Deployments, Services, scaling, and rolling updates.

## Prerequisites

- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed

## Exercise Flow

### 1. Create the Cluster

```bash
./setup-cluster.sh
kubectl get nodes
```

Expected observation: one Ready node is available, usually named `train-station-control-plane`.

### 2. Deploy nginx (3 replicas)

```bash
kubectl apply -f 01-deploy-nginx.yaml
kubectl get pods -l app=nginx
kubectl describe deployment nginx
```

Expected observation: three nginx Pods reach `Running` with `READY` showing `1/1`, and the Deployment reports three available replicas.

### 3. Expose with a Service

```bash
kubectl apply -f 02-service.yaml
kubectl get svc nginx
# Test connectivity from within the cluster:
kubectl run curl --rm -it --image=curlimages/curl -- curl http://nginx
```

Expected observation: the Service has a stable ClusterIP, and the curl command returns the nginx welcome HTML from inside the cluster.

### 4. Scale to 5 Replicas

```bash
kubectl apply -f 03-scale.yaml
kubectl get pods -l app=nginx -w
```

Expected observation: the Pod list grows to five Ready Pods without changing the Service.

### 5. Rolling Update to nginx:1.25

```bash
kubectl apply -f 04-rolling-update.yaml
kubectl rollout status deployment/nginx
kubectl describe deployment nginx | grep Image
```

Expected observation: rollout status reports `successfully rolled out`, and the Deployment image shows `nginx:1.25`.

### 6. Rollback (optional)

```bash
kubectl rollout undo deployment/nginx
kubectl rollout status deployment/nginx
kubectl describe deployment nginx | grep Image
```

Expected observation: rollout status reports success again, and the image returns to the previous nginx tag.

### 7. Teardown

```bash
./teardown.sh
```

Expected observation: the kind cluster is deleted, and `kubectl get nodes` no longer returns the lab cluster.

## Key Concepts Practiced

- Creating and inspecting Deployments
- Service discovery with ClusterIP
- Declarative scaling
- Rolling updates and rollbacks

## Deliverable

Capture a command worksheet with the command, output snippet, and learner note for each exercise. The worksheet should prove you can create, inspect, update, roll back, and clean up a basic Kubernetes workload.
