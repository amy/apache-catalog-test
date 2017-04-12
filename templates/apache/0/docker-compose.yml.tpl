version: '2'
services:
  tomcat1:
    image: tomcat:8.0
    scale: 1
    ports:
      - "8080:80"
    expose:
      - "90"
  apache:
    image: php:apache
    scale: 1
    links:
      - tomcat1
    ports:
      - "8080:80"
    expose:
      - "90"