# What this image does

When you execute this image, it will restore a data folder's file system from a [Duplicity](http://duplicity.nongnu.org/) backup. It works in conjuction
with [volume-backup](https://hub.docker.com/r/kramergroup/volume-backup/).

This is an adaption of [yaronr/backup-volume-container](https://hub.docker.com/r/yaronr/backup-volume-container/) with the following changes:

- Only restore after start
- Use environment variable BUCKET_URL for the backup url (e.g., `s3://s3.amazonaws.com/<bucket_name>/backup`)

# Features

- Secure: Encrypted and signed archives, and transport
- Bandwidth and space efficient
- Standard file format: tar + rdiff
- Choice of remote protocol: scp/ssh, ftp, rsync, HSI, WebDAV, Tahoe-LAFS, and Amazon S3
- Choice of backend: S3 Amazon Web Services, Google Cloud Storage, Rackspace Cloud, Dropbox, copy.com, ftp, ftps, gdocs, gio, rsync, mega, swift...

This image uses Duplicity for backup and restore. Go to the [Duplicity docs](http://duplicity.nongnu.org/) to see more.
Backups are incremental, and can be encrypted.

> It's important to keep this value high enough, else you will be creating a lot of backups.

# Configuration

| variable                | Default | Description                                                                                            |
| ----------------------- | ------- | ------------------------------------------------------------------------------------------------------ |
| `BUCKET_URL`            | none    | The backup location. See [Duplicity docs](http://duplicity.nongnu.org/) for details                    |     
| `AWS_ACCESS_KEY_ID`     | none    | The S3 access key                                                                                      |     
| `AWS_SECRET_ACCESS_KEY` | none    | The secret S3 key                                                                                      |     
| `QUIET_PERIOD`          | 60      | Quiet period before backup is initiated in seconds.                                                    |     
| `DUPLICITY_OPTIONS`     | none    | Optional additional dubplicity options. See [Duplicity docs](http://duplicity.nongnu.org/) for details |     

# Usage

## Docker

This container is meant for single execution

```
docker run -it --rm -v $(pwd):/var/backup \
       -e AWS_ACCESS_KEY_ID=<your_s3_key_id> \
       -e AWS_SECRET_ACCESS_KEY=<your_s3_access_key> \
       -e BUCKET_URL=s3://<bucket-name> kramergroup/volume-restore
```

## Kubernetes

Usage as an initContainer:
