#!/bin/sh
#Stop if anything fails in this script:
set -e

#1)WordPress directory preparation

#2)Install WP-CLI

#3)Wait for MariaDB

#4)Download WordPress

#5)Create wp-config.php

#6)Install WordPress

#7)Start PHP-FPM (for debian:bookworm fpm8.2 is the version available)
php-fpm8.2 -F