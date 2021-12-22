#!/bin/bash

filename=$(date +'%Y%m%d-%H%M')-$RANDOM.gz

echo "Exporting PostgreSQL data as $filename"

if [ "$PGPASS" != "" ]; then
  pg_dump -f $filename -Z 5 -U $PGUSER -W $PGPASS
else
  pg_dump -f $filename -Z 5 -U $PGUSER --no-password
fi

echo "PostgreSQL data exported, uploading $filename to GCS (gs://${GCS_BUCKET})"

gsutil -m mv /backups/$filename gs://${GCS_BUCKET}/

echo "Archive successfully $filename uploaded to gs://${GCS_BUCKET}"

exit 0
