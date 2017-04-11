version: '2'
services:
  tomcat1:
    image: tomcat:8.0
    scale: 1
    ports:
      - "8888:8080"