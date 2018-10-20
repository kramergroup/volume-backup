# What this image does

When you execute this image, it will restore a data folder's file system from a [Duplicity](http://duplicity.nongnu.org/) backup. It works in conjunction with [volume-backup](https://hub.docker.com/r/kramergroup/volume-backup/).

This is an adaption of [yaronr/backup-volume-container](https://hub.docker.com/r/yaronr/backup-volume-container/) with the following changes:

- Only restore after start
- Use environment variable `BUCKET_URL` for the backup url (e.g., `s3://s3.amazonaws.com/<bucket_name>/backup`)

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

Usage as a Kubernetes Job:

```yaml
kind: Job
apiVersion: batch/v1
metadata:
  name: restore-volume
  namespace: default
spec:
  template:
    spec:
      volumes:
        # The data volume should map to the destination of the restore
        - name: data
          persistentVolumeClaim:
            claimName: <restore-to-pvc>
      containers:
        - name: restore
          image: kramergroup/volume-restore
          env:
            - name: AWS_ACCESS_KEY_ID
              value: <your_s3_key_id>
            - name: AWS_SECRET_ACCESS_KEY
              value: <your_s3_access_key>
            - name: BUCKET_URL
              value: 's3://<bucket-name>'
            - name: DUPLICITY_OPTIONS
              value: '--force'
          resources: {}
          volumeMounts:
            - name: data
              mountPath: /var/backup
      restartPolicy: OnFailure
```

Note the additional '--force' option to Duplicity, which is needed because the mountpoint is created by Kubernetes before Duplicity is called.
