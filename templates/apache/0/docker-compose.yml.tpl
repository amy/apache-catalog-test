version: '2'
services:
  tomcat1:
    image: tomcat:8.0
    scale: 1
    ports:
      - "80:80"
    expose:
      - "80"
  apache:
    image: php:apache
    scale: 1
    links:
      - tomcat1
    ports:
      - "80:80"
    expose:
      - "80"