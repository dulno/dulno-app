FROM ${DOCKER_REGISTRY}/dulno-web-proxy:latest

ARG SERVER_NAME
ENV SERVER_NAME=${SERVER_NAME}

COPY /build/web/ /dulno/app/

COPY /web/nginx.conf /etc/nginx/nginx.conf
COPY /web/app /etc/nginx/sites-enabled/app

RUN mkdir -p /var/cache/nginx/client_temp && chown -R 1000:1000 /etc/nginx/sites-enabled /var/cache/nginx

USER 1000

CMD ["/bin/sh", "-c", "envsubst '$SERVER_NAME' < /etc/nginx/sites-enabled/app > /tmp/app && mv /tmp/app /etc/nginx/sites-enabled/app && exec nginx -g 'daemon off;'"]