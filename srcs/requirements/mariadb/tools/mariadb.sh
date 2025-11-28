#Start service ("service mysql start" - does the same as: "service mariadb start")
service mysql start;

#MariaDB needs 1-5 seconds to initialize
echo "Waiting for MariaDB to start..."
until mysqladmin ping --silent; do
    sleep 1
done

#Create DB tables
mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"

mysql -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@%' IDENTIFIED BY '${SQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${SQL_ROOT_PASSWORD}' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

mysqladmin -p${SQL_ROOT_PASSWORD} shutdown

exec mysqld_safe