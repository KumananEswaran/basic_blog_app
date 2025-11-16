# syntax=docker/dockerfile:1

# ------------------------------
# Base image
# ------------------------------
ARG RUBY_VERSION=3.4.1
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install basic packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        curl \
        libjemalloc2 \
        libvips \
        postgresql-client \
        nodejs \
        npm \
        yarn \
    && ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Set production environment variables
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# ------------------------------
# Build stage
# ------------------------------
FROM base AS build

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        build-essential \
        git \
        libpq-dev \
        libyaml-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Copy Gemfiles and install gems
COPY Gemfile Gemfile.lock vendor ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile -j 1 --gemfile

# Copy the full app
COPY . .

# Precompile bootsnap for faster boot
RUN bundle exec bootsnap precompile -j 1 app/ lib/

# ------------------------------
# Precompile assets for production
# ------------------------------
ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

# Rails 8: prevent database connection during assets precompile
ENV DATABASE_URL=postgres://dummy:dummy@localhost/dummy

# Precompile Rails assets
RUN bin/rails assets:precompile

# ------------------------------
# Final production image
# ------------------------------
FROM base

# Create non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash rails
USER 1000:1000

# Copy gems and app from build stage
COPY --chown=rails:rails --from=build /usr/local/bundle /usr/local/bundle
COPY --chown=rails:rails --from=build /rails /rails

# Entrypoint to prepare DB
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose default Rails port
EXPOSE 80

# Start server (can be overridden)
CMD ["./bin/thrust"]
