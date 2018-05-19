FROM alpine:latest

ENV AWS_ACCESS_KEY_ID foobar_aws_key_id
ENV AWS_SECRET_ACCESS_KEY foobar_aws_access_key
ENV BUCKET_URL foobar_aws_bucket

ENV INOTIFYWAIT_EXCLUDE 'matchnothing^'

ENV QUIET_PERIOD 60

RUN apk add --no-cache bash python py-pip duplicity inotify-tools curl ca-certificates && \
    pip install fasteners && \
    curl https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt -o /usr/local/share/ca-certificates/isrg-x3.crt && \
    curl https://letsencrypt.org/certs/letsencryptauthorityx1.pem.txt -o /usr/local/share/ca-certificates/isrg-x1.crt && \
    update-ca-certificates && \
    apk del py-pip curl

VOLUME /var/backup

COPY ./run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
