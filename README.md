# docker-mongodump-gcs
A simple Docker container to perform a `mongodump` command and upload the archive file to GCS.

This container is meant to be used as a cronjob with Kubernetes.

The service account running the container needs to have write access to the destination bucket, as this container makes use of `gsutil`.

# Volumes
You can mount a volume on `/backups` if you want to collect the intermediate archives, or give more space to your container for the backup process.

# Cron Schedule Syntax

```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
# │ │ │ │ │                                   7 is also Sunday on some systems)
# │ │ │ │ │
# │ │ │ │ │
# * * * * *
```
Please refer to https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#cron-schedule-syntax


## Kubernetes definition example
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: mongodb-backup
spec:
  schedule: "0 */6 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: mongodump-gcs-cron
            image: openrm/mongodump-gcs:latest
            imagePullPolicy: IfNotPresent
            env:
            - name: MONGO_URI
              valueFrom:
                secretKeyRef:
                  name: mongodb
                  key: uri
            - name: GCS_BUCKET
              value: "backup_bucket_name"
```
In this simple example, the cron is started every 6 hours.

## Terraform
```tf

resource "kubernetes_cron_job_v1" "mongodb_backup" {
  metadata {
    name = "mongodb-backup"
  }
  spec {
    schedule                  = "0 */6 * * *"
    job_template {
      spec {
        template {
          spec {
            container {
              name            = "mongodump-gcs-cron"
              image           = "openrm/mongodump-gcs:latest"
              env = {
                name = GCS_BUCKET
                value = "backup_bucket_name"
              }
              env = {
                name = MONGO_URI
                value_from {
                  secret_key_ref {
                    name = "mongodb"
                    key  = "uri"
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```
In this simple example, the cron is started every 6 hours.
