---
title: "Kustomize Examples"
type: repo
difficulty: intermediate
tier: free
platform: "CNCF"
url: "https://github.com/kubernetes-sigs/kustomize"
tags: ["kustomize", "kubernetes", "configuration", "gitops"]
stars: 11000
---

# Kustomize Examples

## Overview

Kustomize is the Kubernetes-native way to customize YAML without turning your manifests into a templating language. The upstream [`kubernetes-sigs/kustomize`](https://github.com/kubernetes-sigs/kustomize) repository is both the source code for the tool and the best collection of examples showing how bases, overlays, patches, generators, replacements, and remote resources work together in practice.

This resource matters because Kustomize shows up in real platform workflows far beyond local experimentation. It is built into `kubectl`, widely used in GitOps pipelines, and often becomes the layer where teams express environment-specific differences without forking entire manifests. If Helm teaches packaging, Kustomize teaches composition and policy-friendly customization of plain Kubernetes objects.

For learners, the examples are most useful when treated like a pattern catalog rather than a repo to read front to back. Start with a minimal base-plus-overlay example, then move to targeted patches, generators, and component reuse. By the time you finish, you should be able to look at a Kubernetes manifest tree and decide which variations belong in a base, which belong in overlays, and which should be avoided because they create hard-to-debug configuration drift.

## Prerequisites

- Basic familiarity with Kubernetes objects such as Deployments, Services, ConfigMaps, and Ingress
- Comfort reading and editing YAML manifests
- `kubectl` installed locally; a recent version is helpful because Kustomize is embedded in `kubectl`
- A disposable Kubernetes cluster such as `kind`, `minikube`, Docker Desktop Kubernetes, or a sandbox cloud cluster
- Working knowledge of Git so you can clone the repository and inspect example directories cleanly

## Key Takeaways

1. **Kustomize keeps manifests plain YAML** - You learn how to customize Kubernetes resources without introducing a separate template language or chart packaging workflow.
2. **Bases and overlays are the core mental model** - The examples show how to define a reusable base once, then layer environment-specific changes on top without copy-pasting whole manifests.
3. **Patches should be narrow and intentional** - Good Kustomize usage relies on small, targeted changes rather than giant overlays that are harder to reason about than the base they modify.
4. **Generators and replacements reduce duplication** - ConfigMaps, Secrets, image substitutions, and field replacements let you keep configuration DRY while still producing valid Kubernetes output.
5. **Kustomize fits naturally into GitOps** - Because the end result is rendered YAML, the examples translate directly into Argo CD, Flux, CI validation, and reviewable pull request workflows.

## How to Use

### Step 1: Start at the upstream repository and README

Open the official repository at [github.com/kubernetes-sigs/kustomize](https://github.com/kubernetes-sigs/kustomize). Read the top-level README first so you understand the current feature set, the relationship to `kubectl`, and where the project points you for examples and documentation. Do not begin by browsing random directories without that framing, because the repo includes both user-facing examples and project internals.

### Step 2: Learn the base-plus-overlay pattern first

Find a simple example that includes:

- A `base/` directory with raw Kubernetes resources
- One or more `overlays/` directories for environments such as `dev` or `production`
- A `kustomization.yaml` file in each layer

Render the overlay locally before applying it:

```bash
kubectl kustomize path/to/overlay
```

Then compare the rendered output with the base manifests. This is the fastest way to understand what Kustomize is actually changing.

### Step 3: Practice the core customization primitives

As you move through the examples, focus on a few concepts in order:

1. `resources` and overlay composition
2. Namespace, labels, and image substitutions
3. Strategic merge or JSON-style patches
4. `configMapGenerator` and `secretGenerator`
5. `replacements` and reusable components

For each one, render the output and explain to yourself exactly which fields changed and why. If you cannot predict the final YAML, you do not yet understand that feature well enough to use it in production.

### Step 4: Apply one rendered overlay to a sandbox cluster

Once you understand a simple example, apply it to a disposable cluster:

```bash
kubectl apply -k path/to/overlay
kubectl get all -n <namespace>
```

Verify that labels, namespaces, image tags, and generated ConfigMaps or Secrets appear the way you expected. This step matters because some Kustomize patterns look obvious in rendered YAML but still interact with cluster behavior in surprising ways.

### Step 5: Build your own small manifest tree

Create a toy app with:

- One base Deployment
- One Service
- Two overlays such as `dev` and `prod`

Use the examples to add realistic differences such as replica counts, image tags, resource limits, or ingress hosts. Keep the base minimal. If you find yourself copying a whole Deployment into every overlay, stop and refactor.

### Step 6: Review common failure modes before adopting it broadly

The most common Kustomize problems are usually design problems:

- Overlays that patch too many fields
- Hidden coupling between directory layout and environment behavior
- Generated resources that break deterministic diffs
- Mixing Kustomize with another templating layer in a way that obscures the final output

Before using Kustomize in a team workflow, decide how you will validate `kubectl kustomize` output in CI and how reviewers should inspect rendered changes.

## Deliverable

Produce an overlay validation note for the lab. Include rendered output for the base, dev, and prod overlays; a short diff showing environment-specific changes; and a reviewer checklist covering namespace, labels, replicas, image tag, ConfigMap values, resource requests, and cleanup.

## Practice Notes

- Treat the repository as source material to inspect, not just clone. Review the README, release history, examples, issues, license, and maintenance signals before deciding whether to reuse it.
- Connect the lesson to cluster operations by noting the workload, namespace, RBAC boundary, rollout behavior, observability signal, and failure mode it helps you manage.
- Completion checkpoint: you can adapt the pattern to a second environment, identify its tradeoffs, and explain the operational risks it introduces.
- Portfolio artifact: create a short note titled "Kustomize Examples - applied takeaway" with the scenario you used, the decision you made, and one follow-up task you would assign to yourself or a team.

## Related Resources

- [Kubernetes Official Kustomize Task](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/) - Upstream Kubernetes documentation for the same workflow shown in the repo examples
- [Argo CD - GitOps Continuous Delivery for Kubernetes](https://argo-cd.readthedocs.io/) - Strong companion when you want to use rendered Kustomize output in a GitOps deployment model
- [AWS Well-Architected Labs](https://wellarchitectedlabs.com/) - Useful contrast for how infrastructure guidance and repeatable environments relate to configuration management choices
- [OpenTofu](https://opentofu.org/docs/) - Helpful for comparing Kubernetes manifest customization with infrastructure-as-code workflows in other layers of the stack
- [Kubernetes Official Tutorials](https://kubernetes.io/docs/tutorials/) - Broader upstream learning path once you are ready to apply Kustomize to more realistic workloads

## Estimated Time

- **Reading the README and identifying the example categories**: 10-15 minutes
- **Working through one base-plus-overlay example locally**: 20-30 minutes
- **Exploring patches, generators, and replacements**: 30-45 minutes
- **Applying an overlay to a sandbox cluster and verifying behavior**: 20-30 minutes
- **Building a small manifest tree of your own**: 30-45 minutes
- **Total for this lesson**: ~2-3 hours for a solid practical introduction
