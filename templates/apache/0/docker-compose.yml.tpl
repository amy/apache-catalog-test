version: '2'
services:
  apache:
    tty: true
    stdin_open: true
    image: php:7.1.3-apache
    volumes:
      - content:/var/www/html
      - config:/root/config
    scale: {{.Values.APACHE_SCALE}}
    labels:
      io.rancher.sidekicks: apache-config
  apache-config:
    tty: true
    image: amycodes/apache-config:latest
    environment:
      APACHE_CONF: |
        ${APACHE_CONF}
    volumes:
      - config:/root
    stdin_open: true
    labels:
      io.rancher.container.pull_image: always
      io.rancher.container.start_once: true
  apache-lb:
    image: rancher/lb-service-haproxy:v0.6.4
    ports:
      - {{.Values.PUBLISH_PORT}}:80
    scale: 1
    lb_config:
      port_rules:
        - source_port: 80
          target_port: 80
          service: apache
          protocol: {{.Values.PROTOCOL}}
    health_check:
      port: 42
      interval: 2000
      unhealthy_threshold: 3
      healthy_threshold: 2
      response_timeout: 2000

volumes:
  content:
    driver: {{.Values.VOLUME_DRIVER}}
  config:
    driver: {{.Values.VOLUME_DRIVER}}
