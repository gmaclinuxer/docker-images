# FROM alpine:latest
FROM rabbitmq:alpine

COPY ./docker-entrypoint.sh ./requirements.txt /

# mariadb
RUN addgroup -S mysql \
    && adduser -S mysql -G mysql \
    && apk add --no-cache mysql mysql-client \
    && rm -f /var/cache/apk/* \
    && awk '{ print } $1 ~ /\[mysqld\]/ && c == 0 { c = 1; print "skip-host-cache\nskip-name-resolve\nlower_case_table_names=1"}' /etc/mysql/my.cnf > /tmp/my.cnf \
    && mv /tmp/my.cnf /etc/mysql/my.cnf \
    && mkdir /run/mysqld \
    && chown -R mysql:mysql /run/mysqld \
    && chmod -R 777 /run/mysqld

# python
ENV PACKAGES="\
  python \
  py-pip \
  python-dev \
  uwsgi-python \
"

RUN apk add --no-cache $PACKAGES \
    && pip install --no-cache-dir -Ur /requirements.txt  --index=http://pypi.open.oa.com/simple/ --trusted-host pypi.open.oa.com \
    && rm -rf ~/.cache

EXPOSE 3306 8000


ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["mysqld", "--user=mysql"]
