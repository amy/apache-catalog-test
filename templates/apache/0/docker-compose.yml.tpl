version: '2'
services:
  apache:
    tty: true
    image: php:7.1.3-apache
    restart: always
    scale: {{.Values.APACHE_SCALE}}
    links:
      - tomcat1
  tomcat1:
    image: tomcat:latest
    scale: 1
    ports:
      - 8888:8080