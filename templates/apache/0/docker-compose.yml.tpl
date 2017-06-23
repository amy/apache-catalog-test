version: '2'
services:
  apache:
    tty: true
    image: php:7.1.3-apache
    restart: always
    ports:
      - "80:80"