version: '2'
services:
  tomcat1:
    image: tomcat:8.0
    scale: 1
  apache:
    image: php:7.1.3-apache
    scale: 1
    ports: 
      - "80:80"
    links:
      - tomcat1:tomcat1