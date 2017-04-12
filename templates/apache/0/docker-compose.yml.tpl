version: '2'
services:
  tomcat1:
    image: tomcat:8.0
    scale: 1
    ports:
      - "8000:8080"
  apache:
    image: php:7.1.3-apache
    scale: 1
    ports: "8080:80"
    link:
      - tomcat1