FROM ${DOCKER_REGISTRY}/dulno-web-proxy:latest

ARG SERVER_NAME
ENV SERVER_NAME=${SERVER_NAME}

COPY /build/web/ /dulno/app/

COPY /proxy/nginx.conf /etc/nginx/nginx.conf
COPY /proxy/proxy /etc/nginx/sites-enabled/proxy

RUN mkdir -p /var/cache/nginx/client_temp && chown -R 1000:1000 /etc/nginx/sites-enabled /var/cache/nginx

USER 1000

CMD ["/bin/sh", "-c", "envsubst '$SERVER_NAME' < /etc/nginx/sites-enabled/proxy > /tmp/proxy && mv /tmp/proxy /etc/nginx/sites-enabled/proxy && exec nginx -g 'daemon off;'"]