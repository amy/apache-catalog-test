version: '2'
services:
  apache:
    tty: true
    image: php:7.1.3-apache
    restart: always
    ports:
{{if (eq .Values.APACHE_SSL "false")}}
      - {{.Values.PUBLISH_PORT}}:80
{{end}}
{{if (eq .Values.APACHE_SSL "true")}}
      - {{.Values.PUBLISH_PORT}}:443
{{end}}
    volumes:
      - content:/var/www/html
      - config:/root/config
    scale: {{.Values.APACHE_SCALE}}
{{if (eq .Values.APACHE_ROLE "reverse-proxy")}}
    external_links:
      - {{.Values.EXTERNAL}}
{{end}}
    command: bash -c "chmod +x /root/config/set-config.sh && /root/config/set-config.sh"
    labels:
      io.rancher.sidekicks: apache-config
      io.rancher.container.pull_image: always
    environment:
      apache_role: {{.Values.APACHE_ROLE}}
      apache_ssl: {{.Values.APACHE_SSL}}
      serverAdmin: {{.Values.SERVER_ADMIN}}
      serverName: {{.Values.SERVER_NAME}}
      serverAlias: {{.Values.SERVER_ALIAS}}
{{if (eq .Values.APACHE_SSL "true")}}
      sslKey: |-
        {{.Values.SSL_KEY}}
      sslCrt: |-
        {{.Values.SSL_CRT}}
      country: {{.Values.COUNTRY}}
      state: {{.Values.STATE}}
      locality: {{.Values.LOCALITY}}
      organization: {{.Values.ORGANIZATION}}
      unit: {{.Values.UNIT}}
      common: {{.Values.COMMON}}
      email: {{.Values.EMAIL}}
{{end}}
{{if (eq .Values.APACHE_ROLE "reverse-proxy")}}
      proxy: {{.Values.PROXY}}
      proxyPort: {{.Values.PROXY_PORT}}
{{end}}
{{if .Values.APACHE_CONF}}
      apache_conf: |
        ${APACHE_CONF}
{{end}}
  apache-config:
    tty: true
    image: amycodes/apache-config:latest
    volumes:
      - config:/root
    stdin_open: true
    labels:
      io.rancher.container.pull_image: always
      io.rancher.container.start_once: true
volumes:
  content:
    driver: {{.Values.VOLUME_DRIVER}}
  config:
    driver: {{.Values.VOLUME_DRIVER}}