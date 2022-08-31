ARG GEOCMS_APP_IMAGE_VERSION
FROM geocms:$GEOCMS_APP_IMAGE_VERSION as base

# ==> wait-for-it
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    wait-for-it && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

FROM base as production
# ==> Entrypoint to configure app
COPY docker/sidekiq/entrypoint /usr/local/bin/entrypoint
RUN chmod u+x /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]


FROM base as development
# ==> Entrypoint to configure app
COPY docker/sidekiq/entrypoint.development /usr/local/bin/entrypoint
RUN chmod u+x /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]
