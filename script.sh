#!/bin/bash

filename=$(date +'%Y%m%d-%H%M')-$RANDOM.sql

echo "Exporting PostgreSQL data as $filename"

if [ "$PGPASS" != "" ]; then
  echo "*:*:$PGDATABASE:$PGUSER:$PGPASS" > ~/.pgpass
  chmod 600 ~/.pgpass
  export PGPASSFILE=~/.pgpass
  pg_dump -f /backups/$filename
else
  pg_dump -f /backups/$filename -U $PGUSER --no-password
fi

echo "PostgreSQL data exported, uploading $filename to GCS (gs://${GCS_BUCKET})"

gsutil -m mv /backups/$filename gs://${GCS_BUCKET}/

echo "Archive successfully $filename uploaded to gs://${GCS_BUCKET}"

exit 0
