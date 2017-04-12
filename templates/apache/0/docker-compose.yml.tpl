version: '2'
services:
  tomcat1:
    image: tomcat:8.0
    scale: 1
    ports:
      - "8000:8080"