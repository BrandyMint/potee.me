# Legacy dev image: Rails 3.2 needs Ruby 2.0, which only builds against
# OpenSSL 1.0, so we compile it on Debian jessie (amd64).
FROM --platform=linux/amd64 debian/eol:jessie

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

ENV BUNDLE_PATH=/bundle BUNDLE_WITHOUT=production:daemons LANG=C.UTF-8
WORKDIR /app
EXPOSE 3007
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3007"]
