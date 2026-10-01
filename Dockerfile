# Rails 3.2 needs Ruby 2.0, which only builds against OpenSSL 1.0,
# so Ruby is compiled on Debian jessie (amd64).
FROM --platform=linux/amd64 debian/eol:jessie AS ruby

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential autoconf bison git curl ca-certificates \
      libssl-dev libreadline-dev zlib1g-dev libyaml-dev libffi-dev \
      libxml2-dev libxslt1-dev libpq-dev postgresql-client \
      imagemagick nodejs \
    && ln -sf /usr/bin/nodejs /usr/local/bin/node \
    && rm -rf /var/lib/apt/lists/*

# jessie's CA bundle is too old for rubygems.org / github.com
ADD https://curl.se/ca/cacert.pem /etc/ssl/certs/cacert-modern.pem
ENV SSL_CERT_FILE=/etc/ssl/certs/cacert-modern.pem \
    GIT_SSL_CAINFO=/etc/ssl/certs/cacert-modern.pem \
    CURL_CA_BUNDLE=/etc/ssl/certs/cacert-modern.pem

ARG RUBY_VERSION=2.0.0-p648
ADD https://cache.ruby-lang.org/pub/ruby/2.0/ruby-${RUBY_VERSION}.tar.gz /tmp/ruby.tar.gz
RUN cd /tmp && tar xzf ruby.tar.gz && cd ruby-${RUBY_VERSION} \
    && ./configure --prefix=/usr/local --disable-install-doc --enable-shared \
    && make -j"$(nproc)" && make install \
    && cd / && rm -rf /tmp/ruby*

RUN gem install bundler -v 1.17.3 --no-rdoc --no-ri
ENV BUNDLE_PATH=/bundle LANG=C.UTF-8
WORKDIR /app

# Development: code and gems are mounted from the host (docker-compose.yml).
FROM ruby AS dev
ENV BUNDLE_WITHOUT=production:daemons
EXPOSE 3007
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3007"]

# Frontend libraries (Bower)
FROM node:18-bookworm-slim AS bower
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/* && npm install -g bower
WORKDIR /app
COPY bower.json .bowerrc ./
RUN bower install --allow-root --config.interactive=false

# Production image
FROM ruby AS production
ENV RAILS_ENV=production RACK_ENV=production \
    BUNDLE_WITHOUT=development:test:daemons:production \
    RAILS_SERVE_STATIC_FILES=1 RAILS_LOG_TO_STDOUT=1 PORT=3000
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3
COPY . .
COPY --from=bower /app/vendor/assets/components vendor/assets/components
RUN cp config/database.yml.example config/database.yml \
    && bundle exec rake assets:precompile
EXPOSE 3000
ENTRYPOINT ["/app/script/docker-entrypoint"]
CMD ["bundle", "exec", "unicorn", "-c", "config/unicorn.docker.rb", "config.ru"]
