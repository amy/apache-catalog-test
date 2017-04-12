version: '2'
services:
  apache:
    image: php:7.1.3-apache
    scale: 1
    ports: 
      - "80:80"
    external_links:
      - tomcat/tomcat:tomcat