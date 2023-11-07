ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION-bullseye as base

ARG TARGETARCH

# ==> System dependencies
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    cron \
    vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

# ==> NodeJS
ARG NODE_MAJOR
RUN curl -sL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash -
RUN apt-get update -qq && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    nodejs

# ==> PostgreSQL
# https://wiki.postgresql.org/wiki/Apt
ARG PG_MAJOR
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
  curl \
  ca-certificates \
  gnupg
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN apt-get update -qq && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    "postgresql-client-${PG_MAJOR}"

# ==> Proj4
RUN \
  wget "https://launchpad.net/ubuntu/+archive/primary/+files/libproj-dev_4.9.3-2_${TARGETARCH}.deb" && \
  wget "https://launchpad.net/ubuntu/+archive/primary/+files/proj-bin_4.9.3-2_${TARGETARCH}.deb" && \
  wget "https://launchpad.net/ubuntu/+archive/primary/+files/libproj12_4.9.3-2_${TARGETARCH}.deb" && \
  wget https://launchpad.net/ubuntu/+archive/primary/+files/proj-data_4.9.3-2_all.deb && \
  dpkg -i *.deb

# ==> Generate empty Rails app
ARG RAILS_VERSION
ENV RAILS_ROOT /app
WORKDIR /tmp
RUN gem install rails --version=$RAILS_VERSION
RUN rails new $RAILS_ROOT --database=postgresql

FROM base as production
# ==> Install real app
WORKDIR $RAILS_ROOT
ENV RAILS_ENV='production'
ENV RACK_ENV='production'
COPY docker/app/Gemfile Gemfile
COPY docker/app/Gemfile.lock Gemfile.lock
RUN bundle install --without development test
COPY docker/app/templates $RAILS_ROOT
RUN bundle exec rake assets:precompile

# ==> Entrypoint to configure app
COPY docker/app/entrypoint /usr/local/bin
RUN chmod u+x /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]

FROM base as development
# ==> Install real app
WORKDIR $RAILS_ROOT
ENV RAILS_ENV='development'
ENV RACK_ENV='development'
COPY docker/app/Gemfile Gemfile
COPY docker/app/Gemfile.lock Gemfile.lock
COPY docker/app/templates $RAILS_ROOT

# ==> Entrypoint to configure app
COPY docker/app/entrypoint.development /usr/local/bin/entrypoint
RUN chmod u+x /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]
