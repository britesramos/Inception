#!/bin/bash

#Stop if anything fails in this script:
set -e

#Start service ("service mysql start" - does the same as: "service mariadb start")
#service mysql start; (Does not work inside Docker, because their is no systemd, no init.d, no background supervisor)
#Start MariaDB server directly, as user mysql, using /var/lib/mysql as its database folder, and runs it in the background '&'.
mysqld --user=mysql --datadir=/var/lib/mysql &

#MariaDB needs 1-5 seconds to initialize
echo "Waiting for MariaDB to start..."
until mysqladmin ping --silent; do
    sleep 1
done

#Create DB tables
mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"

mysql -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${SQL_ROOT_PASSWORD}' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

mysqladmin -p${SQL_ROOT_PASSWORD} shutdown

#Starts MariaDB in the foreground, run as mysql user and forces server logs to stdout - which means that in docker with appear in docker logs.
#With exec MariaDB becomes PID1 (If MariaDB crashes, the container will not keep running.)
exec mysqld --user=mysql --console