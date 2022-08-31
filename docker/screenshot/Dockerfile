FROM node:16-buster

# ==> System dependencies
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    git \
    phantomjs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

RUN mkdir -p /app

WORKDIR /app
RUN git clone https://github.com/phpgeekfr/screenshot-as-a-service.git .
COPY docker/screenshot/package.json /app/package.json

ENV NODE_ENV=production
RUN npm install

COPY docker/screenshot/templates/config/production.yml /app/config/production.yml

# ==> Entrypoint to configure app
COPY docker/screenshot/entrypoint /usr/local/bin
RUN chmod u+x /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]

#==> Git config to patch delay in entrypoint
RUN git config --global user.email "geocms@example.com" && \
    git config --global user.name "GeoCMS"

CMD ["node", "app"]
