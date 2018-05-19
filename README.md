# What this image does

When you execute this image, it will monitor the data folder's file system for changes (create, modify, add, remove) - recursively.
If a change is detected, it will wait for a 'quiet period' of N seconds, before initiating an incremental backup to the underlying store. Quiet period == no changes.

This is an adaption of [yaronr/backup-volume-container](https://hub.docker.com/r/yaronr/backup-volume-container/) with the following changes:

- No automatic restore after start
- Use environment variable BACKUP_URL for the backup url (e.g., `s3://s3.amazonaws.com/<bucket_name>/backup`)

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

## Sytemd unit file

Usage as a systemd service with unit file that shows how you could use it:

```
ExecStartPre=-/usr/bin/rm -rf ${DATA_DIR}
ExecStartPre=-/usr/bin/mkdir ${DATA_DIR}

ExecStart=/bin/bash -c  ' \     
  /usr/bin/docker run \     
    -v  ${DATA_DIR}:/var/backup \  
    --name=${CONTAINER_NAME} \  
    --rm \
    -e AWS_ACCESS_KEY_ID=<ID> \
    -e AWS_SECRET_ACCESS_KEY=<SECRET> \
    -e BUCKET_URL=s3://s3.amazonaws.com/<bucket_name>/backup \
    -e QUIET_PERIOD=60 \
    --privileged  \
    kramergroup\volume-backup'
```

## Kubernetes

Usage as a pod container:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mysql-with-backup
  labels:
    app: mysql
  namespace: default
spec:
  containers:
    - name: db
      image: mysql
      ports:
        - containerPort: 8080
      volumeMounts:
      - name: data
        mountPath: /var/lib/mysql
      env:
      - name: MYSQL_ROOT_PASSWORD
        value: example
    - name: backup
      image: kramergroup/volume-backup
      volumeMounts:
      - name: data
        mountPath: /var/backup
      env:
      - name: AWS_ACCESS_KEY_ID
        value: {Your AWS access key}
      - name: AWS_SECRET_ACCESS_KEY
        value: {Your AWS secret}
      - name: BUCKET_URL
        value: s3://{Your Bucket}/mysql-backup
  volumes:
  - name: data
    emptyDir: {}
```
