# Lab 02: Challenge Exercises

Work through these exercises in order. Each builds on concepts from the previous one.

## Exercise 1: Deploy and Verify (Beginner)

Deploy the echoserver application and confirm it is working.

1. Run `make deploy`
2. Verify all pods are Running and Ready
3. Use `kubectl port-forward svc/echoserver 8080:80` to access the service
4. Curl `http://localhost:8080` and confirm you receive a response

**Success criteria:** All pods Running, HTTP 200 response from the service.

---

## Exercise 2: ConfigMap Changes (Beginner)

Modify the ConfigMap and observe how changes propagate.

1. Edit `configmap.yaml` — change `LOG_LEVEL` to `debug`
2. Apply the change with `kubectl apply -f configmap.yaml`
3. Check if existing pods picked up the change (hint: they won't automatically)
4. Force a rollout: `kubectl rollout restart deployment/echoserver`
5. Verify the new env var in a pod: `kubectl exec <pod-name> -- env | grep LOG_LEVEL`

**Question:** Why don't ConfigMap changes automatically propagate to running pods?

---

## Exercise 3: Scaling and Load Distribution (Intermediate)

Observe how Kubernetes distributes traffic across replicas.

1. Scale to 5 replicas: `make scale REPLICAS=5`
2. In one terminal, run: `kubectl port-forward svc/echoserver 8080:80`
3. In another terminal, make 20 requests and observe the hostname header:
   ```bash
   for i in $(seq 1 20); do curl -s http://localhost:8080 | grep -o '"hostname":"[^"]*"'; done | sort | uniq -c
   ```
4. Scale back down to 2 and repeat — observe the distribution changes

**Question:** What scheduling strategy does the Service use by default? How would you change it?

---

## Exercise 4: Rolling Updates and Rollbacks (Intermediate)

Perform a rolling update and practice recovery.

1. Update the image: `make update IMAGE=ealen/echo-server:latest`
2. Watch the rollout: `kubectl rollout status deployment/echoserver`
3. Check revision history: `kubectl rollout history deployment/echoserver`
4. Now simulate a bad deploy: `make update IMAGE=ealen/echo-server:nonexistent`
5. Observe the failed pods: `kubectl get pods -l app=echoserver`
6. Rollback: `make rollback`
7. Confirm the deployment is healthy again

**Question:** What does `maxUnavailable` control during a rolling update? What happens if you set it to 0?

---

## Exercise 5: Resource Limits and Pod Eviction (Advanced)

Explore what happens when pods exceed their resource limits.

1. Create a new file `stress-deployment.yaml` based on `deployment.yaml` with:
   - Memory limit of 32Mi
   - A command override that allocates memory: `["sh", "-c", "dd if=/dev/zero of=/dev/null bs=1M"]`
2. Deploy it and observe what happens (check `kubectl describe pod` for OOMKilled events)
3. Experiment with different limit values
4. Add a `PodDisruptionBudget` that ensures at least 1 pod is always available:
   ```yaml
   apiVersion: policy/v1
   kind: PodDisruptionBudget
   metadata:
     name: echoserver-pdb
   spec:
     minAvailable: 1
     selector:
       matchLabels:
         app: echoserver
   ```
5. Try draining a node and observe how the PDB protects availability

**Question:** What is the difference between `requests` and `limits`? When does the scheduler use each?
