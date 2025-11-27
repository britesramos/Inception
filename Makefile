all:
    mkdir -p /home/sramos/data/mariadb
    mkdir -p /home/sramos/data/wordpress
    docker-compose -f srcs/docker-compose.yaml up -d --build