# Lab 03: Official Tutorial Practice

This lab turns the official Kubernetes tutorial flow into repeatable local exercises using the included echoserver manifests.

## Prerequisites

- A local Kubernetes cluster such as kind or minikube
- `kubectl` configured for that cluster
- `make`

## Exercise Flow

### 1. Deploy the Sample App

```bash
make deploy
make status
```

Expected observations:

- `deployment.apps/echoserver` exists with two desired replicas.
- Pods selected by `app=echoserver` become `Running` and `READY 1/1`.
- `service/echoserver` exposes port `80` on NodePort `30080`.

### 2. Verify the Service Path

```bash
kubectl port-forward svc/echoserver 8080:80
curl -i http://localhost:8080
```

Expected observation: curl returns `HTTP/1.1 200 OK` and a response body that includes request details from the echoserver app.

### 3. Practice Troubleshooting Commands

```bash
kubectl describe deployment echoserver
kubectl get events --sort-by=.lastTimestamp | tail
kubectl logs -l app=echoserver --tail=20
kubectl rollout history deployment/echoserver
```

Expected observations:

- Deployment conditions show available replicas.
- Events explain scheduling, image pulls, scaling, or rollout activity.
- Logs prove the application is receiving requests.
- Rollout history records image changes after update exercises.

### 4. Run the Challenge Exercises

Work through `exercises.md` in order. Use `make clean` when finished.

Expected observation: every exercise has a success check and a short written answer explaining what Kubernetes controller behavior you observed.

## Deliverable

Submit a troubleshooting checklist with the commands above, one healthy output snippet, one intentionally broken rollout, and the rollback command that restored service.
