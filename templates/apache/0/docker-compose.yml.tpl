version: '2'
services:
  apache:
    tty: true
    image: php:7.1.3-apache
    restart: always
    ports:
      - {{.Values.PUBLISH_PORT}}:80
    volumes:
      - content:/var/www/html
      - config:/root/config
    scale: {{.Values.APACHE_SCALE}}
{{if .Values.APACHE_CONF}}
    command: bash -c "chmod +x /root/config/set-config.sh && /root/config/set-config.sh"
    labels:
      io.rancher.sidekicks: apache-config
      io.rancher.container.pull_image: always
    environment:
      apache_role: {{.Values.APACHE_ROLE}}
      apache_conf: |
        ${APACHE_CONF}
  apache-config:
    tty: true
    image: amycodes/apache-config:latest
    volumes:
      - config:/root
    stdin_open: true
    labels:
      io.rancher.container.pull_image: always
      io.rancher.container.start_once: true
{{end}}
volumes:
  content:
    driver: {{.Values.VOLUME_DRIVER}}
  config:
    driver: {{.Values.VOLUME_DRIVER}}
