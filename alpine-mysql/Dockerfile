# FROM alpine:latest
FROM rabbitmq:alpine

COPY ./docker-entrypoint.sh ./requirements.txt /
COPY ./extra.sh /etc/profile.d/

ENV LANG=en_US.UTF-8 \
    TZ=Asia/Shanghai \
    ROOT_PASSWORD=root

# using on arukas 
# RUN echo -e "https://mirror.tuna.tsinghua.edu.cn/alpine/latest-stable/main\n" > /etc/apk/repositories

# mariadb
RUN addgroup -S mysql \
    && adduser -S mysql -G mysql \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache mysql mysql-client \
    && rm -f /var/cache/apk/* \
    && awk '{ print } $1 ~ /\[mysqld\]/ && c == 0 { c = 1; print "skip-host-cache\nskip-name-resolve\nlower_case_table_names=1"}' /etc/mysql/my.cnf > /tmp/my.cnf \
    && mv /tmp/my.cnf /etc/mysql/my.cnf \
    && mkdir /run/mysqld \
    && chown -R mysql:mysql /run/mysqld \
    && chmod -R 777 /run/mysqld

RUN apk --update add openssh \
        supervisor \
	&& sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
	&& echo "root:${ROOT_PASSWORD}" | chpasswd \
	&& mkdir -p /var/logs/supervisor \
	&& mkdir -p /var/run/supervisor \
	&& rm -rf /var/cache/apk/* /tmp/*

RUN ssh-keygen -A

# python
ENV PACKAGES="\
  python \
  py-pip \
  python-dev \
"

RUN apk add --no-cache $PACKAGES \
    && pip install --no-cache-dir -Ur /requirements.txt  --index=http://pypi.open.oa.com/simple/ --trusted-host pypi.open.oa.com \
    # && pip install --no-cache-dir -Ur /requirements.txt  --index=http://mirrors.aliyun.com/pypi/simple/  --trusted-host mirrors.aliyun.com \
    && rm -rf ~/.cache

EXPOSE 3306 8000 22


ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["mysqld", "--user=mysql"]
