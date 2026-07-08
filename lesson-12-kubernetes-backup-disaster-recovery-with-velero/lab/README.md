# Lab 12: Kubernetes Backup and Disaster Recovery with Velero

Use this lab to install Velero against an S3 bucket, take both manual and scheduled backups, simulate a disaster by deleting a namespace, and restore it.

## Prerequisites

- A Kubernetes cluster with `kubectl` admin access
- [Velero CLI](https://velero.io/docs/main/basic-install/#install-the-cli) installed
- An AWS account, an S3 bucket for backups, and an IAM user with S3 (and EC2 snapshot, if using PV snapshots) permissions
- A test namespace with disposable workloads you're comfortable deleting (`test-app` is used throughout this lab)

## Exercise Flow

### 1. Install Velero Pointed at the S3 Bucket

```bash
cp credentials-velero.example credentials-velero
# edit credentials-velero with your real AWS access key and secret

chmod +x velero-install.sh
BUCKET=my-velero-backups REGION=us-east-1 ./velero-install.sh
```

Expected observation: the script installs the Velero server and CRDs into a new `velero` namespace, and `kubectl get pods -n velero` shows the `velero` deployment pod reach `Running`.

### 2. Verify the Backup Location

```bash
velero backup-location get
```

Expected observation: the default `BackupStorageLocation` shows `PHASE` as `Available`, confirming Velero can read and write to your S3 bucket.

### 3. Take a Manual On-Demand Backup

```bash
kubectl create namespace test-app
kubectl create deployment nginx --image=nginx:1.25 -n test-app
kubectl expose deployment nginx --port=80 -n test-app

velero backup create test-backup --include-namespaces test-app
velero backup describe test-backup
```

Expected observation: `velero backup describe` reports `Phase: Completed`, and lists the Deployment, Service, and Pod resources it captured from `test-app`.

### 4. Apply the Schedule and Verify It Registers

```bash
kubectl apply -f backup-schedule.yaml
velero schedule get
```

Expected observation: `daily-backup` appears with `SCHEDULE` showing `0 2 * * *` and `STATUS` as `Enabled`. Velero will now create a new backup automatically at 02:00 UTC every day and expire backups older than the 30-day TTL.

### 5. Simulate a Disaster

This is the disaster recovery simulation — treat it as a stand-in for an accidental `kubectl delete`, a bad `helm uninstall`, or a fat-fingered namespace cleanup in production:

```bash
kubectl delete namespace test-app
kubectl get all -n test-app
```

Expected observation: the namespace and everything in it — the Deployment, the Service, the Pods — is gone. `kubectl get all -n test-app` returns "No resources found" or a "not found" error, exactly as it would after a real accidental deletion.

### 6. Restore from the Backup

```bash
velero restore create --from-backup test-backup
velero restore get
```

Expected observation: a new restore object appears, and its `STATUS` progresses to `Completed`.

### 7. Verify the Restore Succeeded

```bash
velero restore describe <restore-name>
kubectl get all -n test-app
```

Expected observation: `velero restore describe` shows zero errors and zero warnings, and `kubectl get all -n test-app` shows the Deployment, Service, and Pods back and healthy — proof the namespace was fully recovered from object storage, not from anything still cached in the cluster.

### 8. Clean Up

```bash
velero backup delete test-backup --confirm
velero restore delete <restore-name> --confirm
kubectl delete namespace test-app
```

Expected observation: `velero backup get` and `velero restore get` no longer list the lab's objects. If this cluster and bucket were stood up only for this lab, also follow the main lesson's `## Cleanup` section to uninstall Velero and remove the S3 bucket and IAM credentials — leaving them running accrues ongoing storage and IAM cost for no reason.

## Deliverable

Submit a command worksheet covering the install verification, the manual backup, the schedule registration, the namespace deletion, and the restore — with the observed output for each step proving the namespace came back after being deleted.
