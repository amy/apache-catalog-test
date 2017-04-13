version: '2'
services:
  apache:
    tty: true
    image: php:7.1.3-apache
    restart: always
{{if (eq .Values.PROTOCOL "none")}}
    ports:
      - {{.Values.PUBLISH_PORT}}:80
{{end}}
    volumes:
      - content:/var/www/html
      - config:/root/config
    scale: {{.Values.APACHE_SCALE}}
{{if .Values.APACHE_CONF}}
  {{if (eq .Values.APACHE_ROLE "webserver")}}
    {{if .Values.APACHE_SSL}}
    command: |
      bash -c "mv /root/config/custom-config.conf /etc/apache2/sites-available &&
      a2enmod ssl && 
      mkdir /etc/apache2/ssl && 
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt <<COMMANDBLOCK
      ${COUNTRY}
      ${STATE}
      ${LOCALITY}
      ${ORGANIZATION}
      ${UNIT}
      ${COMMON}
      ${EMAIL}
      COMMANDBLOCK
      apache2-foreground"
    {{end}}
    {{if not .Values.APACHE_SSL}}
    command: |
      bash -c "mv /root/config/custom-config.conf /etc/apache2/sites-available && 
      a2ensite custom-config.conf && 
      a2dissite 000-default.conf && 
      apache2-foreground"
    {{end}}
  {{end}}
  {{if (eq .Values.APACHE_ROLE "reverse-proxy")}}
    {{if not .Values.APACHE_SSL}}
    command: |
      bash -c "mv /root/config/custom-config.conf /etc/apache2/sites-available
      apt-get update
      apt-get -y upgrade
      apt-get install -y build-essential &&
      apt-get install -y libapache2-mod-proxy-html libxml2-dev &&
      a2enmod proxy &&
      a2enmod proxy_http &&
      a2enmod proxy_ajp &&
      a2enmod rewrite &&
      a2enmod deflate &&
      a2enmod headers &&
      a2enmod proxy_balancer &&
      a2enmod proxy_connect &&
      a2enmod proxy_html
      a2ensite custom-config.conf && 
      a2dissite 000-default.conf && 
      apache2-foreground"
    {{end}}
    external_links:
      - {{.Values.EXTERNAL}}
  {{end}}
    labels:
      io.rancher.sidekicks: apache-config
    depends_on: 
      - apache-config
  apache-config:
    tty: true
    image: amycodes/apache-config:latest
    environment:
      apache_conf: |
        ${APACHE_CONF}
    volumes:
      - config:/root
    stdin_open: true
    labels:
      io.rancher.container.pull_image: always
      io.rancher.container.start_once: true
{{end}}
{{if not (eq .Values.PROTOCOL "none")}}
  apache-lb:
    image: rancher/lb-service-haproxy:v0.6.4
    ports:
      - {{.Values.PUBLISH_PORT}}:80
    scale: 1
    lb_config:
  {{if (eq .Values.PROTOCOL "custom")}}
      config: |
        ${CUSTOM}
  {{else}}
    {{if ((eq .Values.PROTOCOL "https") or (eq .Values.PROTOCOL "tls") or (eq .Values.PROTOCOL "sni"))}}
      default_cert: {{.Values.CERT_NAME}}
    {{end}}
      port_rules:
        - source_port: 80
          target_port: 80
          service: apache
          protocol: {{.Values.PROTOCOL}}
  {{end}}
    health_check:
      port: 42
      interval: 2000
      unhealthy_threshold: 3
      healthy_threshold: 2
      response_timeout: 2000
{{end}}
volumes:
  content:
    driver: {{.Values.VOLUME_DRIVER}}
  config:
    driver: {{.Values.VOLUME_DRIVER}}
