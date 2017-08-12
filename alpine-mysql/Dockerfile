# FROM alpine:latest
FROM rabbitmq:alpine

COPY ./entrypoint.sh /usr/bin/
COPY ./requirements.txt /root/
COPY ./extra.sh /etc/profile.d/

ENV APK_REP="mirrors.ustc.edu.cn" \
    ROOT_PASSWD="root" \
    # PYPI_HOST="pypi.open.oa.com/simple" \
    PYPI_HOST="mirrors.aliyun.com/pypi/simple" \
    # PYPI_HOST="pypi.douban.com/simple" \
    PACKAGES="\
    python \
    py-pip \
    python-dev \
    " 

RUN sed -i "s/dl-cdn.alpinelinux.org/${APK_REP}/g" /etc/apk/repositories

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

# openssh
RUN apk --no-cache add openssh \
	&& sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
	&& echo "root:${ROOT_PASSWD}" | chpasswd \
	&& rm -rf /var/cache/apk/* /tmp/*

RUN apk add --no-cache $PACKAGES \
    && pip install --no-cache-dir -Ur /root/requirements.txt  --index=http://${PYPI_HOST} --trusted-host ${PYPI_HOST%%/*} \
    && rm -rf ~/.cache

EXPOSE 3306 8000 22 15671 15672


ENTRYPOINT ["entrypoint.sh"]

CMD ["django"]
