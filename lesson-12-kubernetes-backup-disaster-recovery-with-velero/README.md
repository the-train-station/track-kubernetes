---
title: "Kubernetes Backup & Disaster Recovery with Velero"
type: lab
difficulty: intermediate
tier: free
tags: ["kubernetes", "velero", "backup", "disaster-recovery"]
---

# Kubernetes Backup & Disaster Recovery with Velero

## Overview

Velero is an open-source tool that backs up and restores Kubernetes cluster resources and, optionally, the data in persistent volumes. A Velero backup captures the Kubernetes API objects in a namespace or cluster — Deployments, Services, ConfigMaps, Secrets, PVC definitions, and more — as versioned data in an external object store such as Amazon S3, and can additionally trigger volume snapshots so the underlying data isn't left behind. Restores replay that captured state back into a cluster, whether that's the same cluster after a mistake or a brand-new cluster in a different region. Velero also supports `Schedule` objects, which turn one-off backups into a recurring, automated process.

Backup and disaster recovery matter for Kubernetes precisely because Kubernetes' self-healing does not cover the failure modes that actually cause outages in practice. A controller restarting a crashed Pod does nothing to help you after `kubectl delete namespace production` was run against the wrong context, after a bad `kubectl apply` overwrites a Deployment with stale config, after `helm uninstall` removes a release along with everything it owned, or after an entire cluster or region becomes unavailable. None of those are things the scheduler or a ReplicaSet controller can undo — they require a copy of your cluster state that lives somewhere else, taken before the mistake happened.

For an intermediate learner, this lesson is where "the cluster is running" and "the cluster is operable" start to diverge. Anyone can deploy a workload; fewer people have practiced recovering one after it's gone. This lesson builds that muscle memory deliberately: you'll install Velero against real object storage, take both a manual and a scheduled backup, delete a namespace on purpose to simulate a disaster, and prove to yourself that the restore actually works — the same verification discipline you'd want before ever relying on a backup during a real incident.

## Prerequisites

- A Kubernetes cluster with `kubectl` admin access (a disposable kind/minikube/k3d cluster is fine for this lab)
- An AWS account with permission to create an S3 bucket and an IAM user
- [Velero CLI](https://velero.io/docs/main/basic-install/#install-the-cli) installed locally
- Comfort with basic `kubectl` operations (create namespace, create deployment, delete namespace)
- Awareness that this lab provisions real, billable AWS resources (S3 storage, IAM credentials) — see the Cleanup section before you finish

## Key Takeaways

1. **Velero backs up more than raw data** - It captures Kubernetes API object definitions (Deployments, Services, ConfigMaps, Secrets) to object storage, and can additionally snapshot the persistent volume data those objects reference.
2. **Kubernetes' self-healing has a blind spot: human error** - Namespace deletion, a bad `kubectl apply`, an accidental `helm uninstall`, or losing an entire cluster or region are not things a controller can undo on its own.
3. **Scheduled backups turn DR from a hope into a process** - A Velero `Schedule` with a cron expression and a TTL (retention window) runs automatically, so recovery doesn't depend on someone remembering to take a backup first.
4. **An untested backup is not a backup** - The only way to know a backup is actually restorable is to restore it, on purpose, before you need it during a real incident — which is exactly what this lab's disaster simulation step does.
5. **Backup infrastructure has an ongoing cost** - The S3 bucket and IAM credentials Velero depends on keep costing money and remain a credential surface until you explicitly tear them down.

## How to Use

### Step 1: Install Velero pointed at the S3 bucket

`lab/velero-install.sh` checks that the `velero` CLI and `kubectl` are installed and that your cluster is reachable, then runs `velero install` wired to an AWS S3 backend using the `velero-plugin-for-aws` plugin. Before running it, copy `lab/credentials-velero.example` to `lab/credentials-velero` and fill in a real AWS access key and secret for an IAM user scoped to your backup bucket. Never commit the filled-in file — it belongs in `.gitignore`.

### Step 2: Verify the backup location

Once installed, confirm Velero can actually reach your bucket with `velero backup-location get`. A `BackupStorageLocation` stuck in anything other than `Available` means a credentials or bucket-permissions problem to fix before you rely on it for anything.

### Step 3: Take a manual, on-demand backup

Create a disposable test namespace with a trivial workload, then back it up directly with `velero backup create test-backup --include-namespaces <namespace>`. This is the same command you'd reach for before a risky change in a real cluster — a manual safety net independent of the schedule.

### Step 4: Apply the Schedule and confirm it registers

`lab/backup-schedule.yaml` defines a Velero `Schedule` that runs daily at 02:00 UTC (`"0 2 * * *"`), scoped to a specific namespace via `includedNamespaces`, with a `720h0m0s` (30-day) TTL so old backups expire automatically instead of accumulating storage cost forever. Apply it and confirm with `velero schedule get`.

### Step 5: Simulate a disaster

Delete the test namespace outright with `kubectl delete namespace <namespace>`. Treat this as the disaster recovery simulation step, not an afterthought — it's standing in for the exact class of incident (accidental deletion, bad apply, bad uninstall) that backups exist to protect against.

### Step 6: Restore from the backup

Run `velero restore create --from-backup test-backup` to replay the captured objects back into the cluster.

### Step 7: Verify the restore actually worked

Check `velero restore describe` for zero errors and zero warnings, and confirm with `kubectl get all -n <namespace>` that the Deployment, Service, and Pods are back and healthy. This verification step is the point of the whole exercise — a restore that "completes" without you checking the actual resources came back is not a verified recovery.

### Step 8: Clean up the lab objects

Delete the test backup and restore objects with `velero backup delete` and `velero restore delete`, and remove the test namespace if it wasn't already replaced by the restore. Then follow the Cleanup section below for the underlying infrastructure.

## Cleanup

This lab provisions real, billable AWS infrastructure — an S3 bucket and IAM credentials — that keep costing money and remain a credential surface until removed. If this was a disposable lab cluster, tear all of it down when you're done:

1. **Uninstall Velero from the cluster**:
   ```bash
   velero uninstall
   ```
   Confirms and removes the `velero` namespace, its CRDs, and its server deployment.

2. **Empty and delete the S3 bucket**:
   ```bash
   aws s3 rm s3://<your-velero-bucket-name> --recursive
   aws s3api delete-bucket --bucket <your-velero-bucket-name> --region <your-aws-region>
   ```
   S3 does not allow deleting a non-empty bucket, so the objects have to go first. Leaving the bucket around after the lab means paying for stored backup data indefinitely.

3. **Revoke the IAM credentials**:
   ```bash
   aws iam delete-access-key --user-name <velero-iam-user> --access-key-id <AWS_ACCESS_KEY_ID>
   ```
   Long-lived IAM access keys are a standing credential risk even when unused. Delete the access key (and the IAM user itself, if it was created solely for this lab) rather than leaving it dormant.

Per this repo's cost-governance conventions, treat any of this infrastructure you leave running past the lab as billable-until-removed — there is no free tier that makes an idle S3 bucket with IAM credentials cost nothing.

## Deliverable

Submit the command worksheet from `lab/README.md` covering install verification, the manual backup, the schedule registration, the simulated namespace deletion, and the restore — plus a short note confirming you completed the Cleanup steps above (or an explanation of why the cluster/bucket are being kept for further practice).

## Self-Assessment

- What's the difference between a Velero backup restoring resource manifests versus restoring persistent volume data — and what do you need configured for the latter to actually work?
- How would you verify a backup is truly restorable before you need it in a real incident, rather than trusting that "Phase: Completed" is enough?
- If your `Schedule`'s TTL is shorter than the interval between backups you actually need for a compliance requirement, what breaks, and how would you catch that before an audit does?
- Your IAM user's S3 permissions are scoped only to `PutObject`/`GetObject` on the backup bucket — what happens to Velero's restore capability if that user's credentials are rotated without updating `credentials-velero` in the cluster?

## Practice Notes

- Run hands-on work in a sandbox and keep a short lab log with commands, screenshots or outputs, resources created, cleanup steps, and the one pattern you would reuse in production.
- Connect the lesson to cluster operations by noting the workload, namespace, RBAC boundary, rollout behavior, observability signal, and failure mode it helps you manage.
- Completion checkpoint: you can adapt the pattern to a second environment, identify its tradeoffs, and explain the operational risks it introduces.
- Portfolio artifact: create a short note titled "Kubernetes Backup & Disaster Recovery with Velero - applied takeaway" with the scenario you used, the decision you made, and one follow-up task you would assign to yourself or a team.

## Related Resources

- [Velero Documentation](https://velero.io/docs/) - Primary reference for installation, backup/restore workflows, and provider plugins
- [Velero AWS Plugin](https://github.com/vmware-tanzu/velero-plugin-for-aws) - Details on the S3 backend and IAM permissions Velero needs
- [Velero Schedule Reference](https://velero.io/docs/main/api-types/schedule/) - Full spec for cron scheduling and TTL-based retention
- [Kubernetes Backup Strategies (CNCF)](https://kubernetes.io/docs/tasks/administer-cluster/) - Broader cluster administration context for where backup fits into operations
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/) - Reference for bucket lifecycle policies, useful for automating backup retention and cost control

## Estimated Time

- **Provisioning the S3 bucket and IAM user, and installing Velero**: 30-45 minutes
- **Verifying the backup location and taking a manual backup**: 15-20 minutes
- **Applying the Schedule and confirming it registers**: 10-15 minutes
- **Simulating the disaster and restoring**: 20-30 minutes
- **Verifying the restore and cleaning up lab objects**: 15-20 minutes
- **Tearing down Velero, the bucket, and IAM credentials**: 15-20 minutes
- **Total for this lesson**: ~2-2.5 hours for a full install-backup-disaster-restore-cleanup cycle
