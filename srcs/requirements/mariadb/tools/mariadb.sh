#!/bin/bash

#Stop if anything fails in this script:
set -e

if [ ! -d "/var/lib/mysql/mysql" ] || [ ! -d "/var/lib/mysql/${SQL_DATABASE}" ]; then
    echo "First time setup - initializing MariaDB..."

	#Start service ("service mysql start" - does the same as: "service mariadb start")
	#service mysql start; (Does not work inside Docker, because their is no systemd, no init.d, no background supervisor)
	#Start MariaDB server directly, as user mysql, using /var/lib/mysql as its database folder, and runs it in the background '&'.
	mysqld --user=mysql --datadir=/var/lib/mysql &

	#MariaDB needs 1-5 seconds to initialize
	echo "Waiting for MariaDB to start..."
	until mysqladmin ping --silent; do
		sleep 1
	done

	#Secure the root account:
	echo "Securing root account..."
	mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
	mysql -u root -p${SQL_ROOT_PASSWORD} -e "DELETE FROM mysql.user WHERE User='';"
	mysql -u root -p${SQL_ROOT_PASSWORD} -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1', '%');"
	mysql -u root -p${SQL_ROOT_PASSWORD} -e "DROP DATABASE IF EXISTS test;"
	mysql -u root -p${SQL_ROOT_PASSWORD} -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"

	#Create DB tables
	mysql -u root -p${SQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"

	mysql -u root -p${SQL_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
	mysql -u root -p${SQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
	mysql -u root -p${SQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${SQL_ROOT_PASSWORD}' WITH GRANT OPTION;"
	mysql -u root -p${SQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"

	mysqladmin -u root -p${SQL_ROOT_PASSWORD} shutdown

	echo "Initialization complete!"
else
	echo "MariaDB already initialized, skipping setup..."
fi

#Starts MariaDB in the foreground, run as mysql user and forces server logs to stdout - which means that in docker with appear in docker logs.
#With exec MariaDB becomes PID1 (If MariaDB crashes, the container will not keep running.)
exec mysqld --user=mysql --console