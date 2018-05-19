#!/bin/bash

if [[ ${AWS_ACCESS_KEY_ID} = "foobar_aws_key_id" || ${AWS_SECRET_ACCESS_KEY} = "foobar_aws_access_key" || ${BUCKET_URL} = "foobar_aws_bucket" ]] ; then
	echo "AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY AWS_BUCKET_URL environment variables MUST be set"
    exit 1
fi

echo "Using ${BUCKET_URL} as S3 URL"
echo "Using ${QUIET_PERIOD} as required quiet (file system inactivity) period before executing backup"
echo
echo "Updating time data to prevent problems with S3 time mismatch"

inotifywait_events="modify,attrib,move,create,delete"

cd /var/backup

# start by restoring the last backup:
# This could fail if there's nothing to restore.
# duplicity $DUPLICITY_OPTIONS --no-encryption ${AWS_BUCKET_URL} .

# Start waiting for file system events on this path.
# After an event, wait for a quiet period of N seconds before doing a backup
while inotifywait -r -e $inotifywait_events --exclude $INOTIFYWAIT_EXCLUDE . ; do
  echo "Change detected."
  while inotifywait -r -t ${QUIET_PERIOD} -e $inotifywait_events --exclude $INOTIFYWAIT_EXCLUDE . ; do
  	echo "waiting for quiet period.."
  done

  echo "starting backup"
  duplicity $DUPLICITY_OPTIONS --no-encryption --allow-source-mismatch --full-if-older-than 7D . ${BUCKET_URL}
  echo "starting cleanup"
  duplicity remove-all-but-n-full 3 $DUPLICITY_OPTIONS --force --no-encryption --allow-source-mismatch ${BUCKET_URL}
  duplicity cleanup $DUPLICITY_OPTIONS --force --no-encryption ${BUCKET_URL}
done
