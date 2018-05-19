#!/bin/bash

if [[ ${AWS_ACCESS_KEY_ID} = "foobar_aws_key_id" || ${AWS_SECRET_ACCESS_KEY} = "foobar_aws_access_key" || ${BUCKET_URL} = "foobar_aws_bucket" ]] ; then
	echo "AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY AWS_BUCKET_URL environment variables MUST be set"
    exit 1
fi

echo "Using ${BUCKET_URL} as S3 URL"
echo

inotifywait_events="modify,attrib,move,create,delete"

cd /var/backup

# start by restoring the last backup:
# This could fail if there's nothing to restore.
duplicity $DUPLICITY_OPTIONS --no-encryption ${BUCKET_URL} .
