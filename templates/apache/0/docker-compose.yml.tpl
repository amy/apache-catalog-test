version: '2'
services:
  apache:
    tty: true
    image: php:7.1.3-apache
    command: bash -c "mv /root/config/custom-config.conf /etc/apache2/sites-available && apache2-foreground && a2ensite /etc/apache2/sites-available/apache.conf && a2dissite /etc/apache2/sites-available/000-default.conf && service apache2 reload"
    volumes:
      - content:/var/www/html
      - config:/root/config
    scale: {{.Values.APACHE_SCALE}}
    privileged: true
    labels:
      io.rancher.sidekicks: apache-config
  apache-config:
    tty: true
    image: amycodes/apache-config:latest
    environment:
      apache_conf: |
        ${APACHE_CONF}
    volumes:
      - config:/root
    stdin_open: true
    privileged: true
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
