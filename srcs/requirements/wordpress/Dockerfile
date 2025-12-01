FROM debian:bookworm

RUN apt update -y && \
	apt upgrade -y && \
	apt install -y \
	curl \
	wget \
	tar \
	php-fpm \
	php-mysql \
	mariadb-client

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/wordpress.sh /usr/local/bin/wordpress.sh
RUN chmod +x /usr/local/bin/wordpress.sh

EXPOSE 9000

CMD ["/usr/local/bin/wordpress.sh"]