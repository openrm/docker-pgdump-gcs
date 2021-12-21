#!/bin/bash

filename=$(date +'%Y%m%d-%H%M')-$RANDOM.tar.gz

echo "Exporting MongoDB data as $filename"

mongodump --uri ${MONGO_URI} --archive=/backups/$filename --gzip

echo "MongDB data exported, uploading $filename to GCS (gs://${GCS_BUCKET})"

gsutil -m mv /backups/$filename gs://${GCS_BUCKET}/

echo "Archive successfully $filename uploaded to gs://${GCS_BUCKET}"

exit 0
