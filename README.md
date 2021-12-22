# docker-pgdump-gcs
A simple Docker container to perform a `pg_dump` command and upload the archive file to GCS. You can specify env variables used by the `pg_dump` to customize the execution (`PGDATABASE`, `PGHOST`, `PGPORT`, etc.).

This container is meant to be used as a cronjob with Kubernetes, and it will simply dump the data as a plain SQL file with compression enabled.

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
  name: postgresql-backup
spec:
  schedule: "0 */6 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: pgdump-gcs-cron
            image: openrm/pgdump-gcs:latest
            imagePullPolicy: IfNotPresent
            env:
            - name: PGDATABASE
              value: "postgresql_database"
            - name: PGHOST
              value: "postgresql_host"
            - name: PGPORT
              value: "postgresql_port"
            - name: PGUSER
              valueFrom:
                secretKeyRef:
                  name: postgresql
                  key: user
            - name: PGPASS
              valueFrom:
                secretKeyRef:
                  name: postgresql
                  key: password
            - name: GCS_BUCKET
              value: "backup_bucket_name"
```
In this simple example, the cron is started every 6 hours.

## Terraform
```tf

resource "kubernetes_cron_job_v1" "postgresql_backup" {
  metadata {
    name = "postgresql-backup"
  }
  spec {
    schedule                  = "0 */6 * * *"
    job_template {
      spec {
        template {
          spec {
            container {
              name            = "pgdump-gcs-cron"
              image           = "openrm/pgdump-gcs:latest"
              env = {
                name = PGDATABASE
                value = postgresql_database
              }
              env = {
                name = PGHOST
                value = postgresql_host
              }
              env = {
                name = PGPORT
                value = postgresql_port
              }
              env = {
                name = PGUSER
                value_from {
                  secret_key_ref {
                    name = "postgresql"
                    key  = "user"
                  }
                }
              }
              env = {
                name = PGPASS
                value_from {
                  secret_key_ref {
                    name = "postgresql"
                    key  = "password"
                  }
                }
              }
              env = {
                name = GCS_BUCKET
                value = "backup_bucket_name"
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
