#!/bin/sh

set -e

[ "$DEBUG" == 'true' ] && set -x

function has_no_such_process(){
    count=`ps -ef |grep $1 |grep -v "grep" |wc -l`
    return $count == 0
}

if [ "$1" = "django" ]; then
    
    export PATH=$PATH:/opt/rabbitmq/sbin::/opt/rabbitmq/bin

    if has_no_such_process "rabbitmq-server"; then
        echo 'Start rabbitmq-server with /usr/local/bin/docker-entrypoint.sh'
        rabbitmq-plugins enable --offline rabbitmq_management
        docker-entrypoint.sh rabbitmq-server &
    fi

    if has_no_such_process "sshd"; then
        echo 'Start sshd in daemon'
        ssh-keygen -A
        /usr/sbin/sshd -D &
    fi


    if has_no_such_process "mysqld"; then

        echo 'Initializing database'
        mysql_install_db --user=mysql --rpm > /dev/null
        echo 'Database initialized'

        # Start MySQL
        mysqld --user=mysql --skip-networking &
        mysql_pid="$!"

        # Wait for MySQL to start
        for i in {30..0}; do
            if "/usr/bin/mysql --protocol=socket --user root -e 'SELECT 1'" &> /dev/null; then
                break
            fi
            echo 'MySQL init process in progress...'
            sleep 1
        done
        if [ "$i" = 0 ]; then
            echo >&2 'MySQL init process failed.'
            exit 1
        fi

        echo "Creating new user"
        /usr/bin/mysql --protocol=socket --user root << EOSQL
            SET @@SESSION.SQL_LOG_BIN=0;
            CREATE USER 'root'@'%';
            GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
            DROP DATABASE IF EXISTS test;
            FLUSH PRIVILEGES;
EOSQL

        # Stop MySQL
        if ! kill -s TERM "$mysql_pid" || ! wait "$mysql_pid"; then
            echo >&2 'MySQL init process failed.'
            exit 1
        fi

        echo
        echo 'MySQL init process done. Ready for start up.'
        echo

        # run forever in mysqld
        mysqld --user=mysql &
    fi

    # run forever in mysqld
    wait "$!" && exit $?

else
    exec "$@"
fi

echo "CMD: $@"
