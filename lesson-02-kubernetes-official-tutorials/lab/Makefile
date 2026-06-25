# Makefile — Lab exercise automation
# Usage: make <target>

.PHONY: deploy scale update rollback status logs clean

# Deploy all resources (configmap, deployment, service)
deploy:
	kubectl apply -f configmap.yaml
	kubectl apply -f deployment.yaml
	kubectl apply -f service.yaml
	@echo ""
	@echo "Deployed. Run 'make status' to check readiness."

# Scale the deployment to a given replica count (default: 4)
REPLICAS ?= 4
scale:
	kubectl scale deployment/echoserver --replicas=$(REPLICAS)
	kubectl rollout status deployment/echoserver
	@echo "Scaled to $(REPLICAS) replicas."

# Update the container image (demonstrates rolling update)
IMAGE ?= ealen/echo-server:0.9.2
update:
	kubectl set image deployment/echoserver echoserver=$(IMAGE)
	kubectl rollout status deployment/echoserver
	@echo "Updated to image: $(IMAGE)"

# Rollback to previous revision
rollback:
	kubectl rollout undo deployment/echoserver
	kubectl rollout status deployment/echoserver
	@echo "Rolled back to previous revision."

# Show current status of all lab resources
status:
	@echo "=== Deployment ==="
	@kubectl get deployment echoserver -o wide
	@echo ""
	@echo "=== Pods ==="
	@kubectl get pods -l app=echoserver -o wide
	@echo ""
	@echo "=== Service ==="
	@kubectl get svc echoserver
	@echo ""
	@echo "=== ConfigMap ==="
	@kubectl get configmap echoserver-config

# Tail logs from all echoserver pods
logs:
	kubectl logs -l app=echoserver --tail=50 -f

# Delete all lab resources
clean:
	kubectl delete -f service.yaml --ignore-not-found
	kubectl delete -f deployment.yaml --ignore-not-found
	kubectl delete -f configmap.yaml --ignore-not-found
	@echo "All lab resources removed."
