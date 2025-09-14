# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.3.1
FROM ruby:$RUBY_VERSION-slim

WORKDIR /rails

ENV RAILS_ENV=development \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        build-essential git libpq-dev libvips pkg-config curl postgresql-client redis-tools && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4

COPY . .

RUN mkdir -p tmp log storage db && \
    rm -rf tmp/cache/bootsnap

EXPOSE 3000

RUN useradd -ms /bin/bash rails && chown -R rails:rails /rails
USER rails

ENTRYPOINT ["bin/docker-entrypoint"]

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
