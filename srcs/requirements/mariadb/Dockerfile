FROM debian:bookworm

RUN apt update -y && \
	apt upgrade -y && \
	apt install -y mariadb-server

RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/mariadb.sh /usr/local/bin/mariadb.sh

RUN chmod +x /usr/local/bin/mariadb.sh

EXPOSE 3306

CMD ["/usr/local/bin/mariadb.sh"]
