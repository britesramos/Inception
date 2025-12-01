#Container's OS(Debian) base image and the penultimate stable version(bookworm)
FROM debian:bookworm

RUN apt update -y && \
	apt upgrade -y && \
	apt install -y nginx openssl

#Remove default NGINX site, this might conflict with our set up.
RUN rm -rf /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default /var/www/html/index.nginx-debian.html

#Create SSL directory
RUN mkdir -p /etc/nginx/ssl

# RUN mkdir -p /var/www/wordpress && \
#     echo "<h1>Welcome to Inception</h1>" > /var/www/wordpress/index.html

#1.Generate new SSL certificate
#2.Where the key is going to be stored
#3.Where the certificate is going to be stored
#4.Specifying the certificate's subject
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/nginx.key \
	-out /etc/nginx/ssl/nginx.crt \
	-subj "/C=NL/ST=Test/L=Amsterdam/O=Inception/OU=Student/CN=sramos.42.fr"

#Copy costum config file to the NGINX installation directory. (This way NGINX will read my costume config file instead of his default file, that I removed in a previous step.)
COPY conf/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 8443

CMD ["nginx", "-g", "daemon off;"]
#Running NGINX in foreground so the docker keeps the container alive.