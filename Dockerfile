# This Dockerfile builds the Plausible binary using an Ubuntu 22.04 Linux Docker Container
# This file is based upon the default Dockerfile located at Plausible/Analytics

# Build Environment (Elixir, Erlang, and Ubuntu Linux)
FROM hexpm/elixir:1.15.7-erlang-26.1.2-ubuntu-jammy-20231004 as buildcontainer
ARG MIX_ENV=small

# Preparation
ENV MIX_ENV=$MIX_ENV
ENV NODE_ENV=production
ENV NODE_OPTIONS=--openssl-legacy-provider

# Custom ERL_FLAGS are passed for (public) multi-platform builds
# to fix qemu segfault, more info: https://github.com/erlang/otp/pull/6340
ARG ERL_FLAGS
ENV ERL_FLAGS=$ERL_FLAGS

# Install build dependencies
RUN apt-get update && apt-get install -y \
  git \
  nodejs \
  yarn \
  python3 \
  ca-certificates \
  wget \
  curl \
  gnupg \
  make \
  gcc \
  libc-dev \
&& rm -rf /var/lib/apt/lists/*

# Install nodejs version 21.0.0 via nodesource PPA
ENV NODE_MAJOR=21
RUN mkdir -p /etc/apt/keyrings && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

# Install latest version of Node Package Manager
RUN npm install npm@latest -g

# Build
RUN mkdir /app
WORKDIR /app

# Mix is an Erlang/Elixir-specific build toolchain
COPY mix.exs ./
COPY mix.lock ./
COPY config ./config
RUN mix local.hex --force && \
  mix local.rebar --force && \
  mix deps.get --only prod && \
  mix deps.compile

COPY assets/package.json assets/package-lock.json ./assets/
COPY tracker/package.json tracker/package-lock.json ./tracker/

RUN npm install --prefix ./assets && \
  npm install --prefix ./tracker

COPY assets ./assets
COPY tracker ./tracker
COPY priv ./priv
COPY lib ./lib
COPY extra ./extra

RUN npm run deploy --prefix ./tracker && \
  mix assets.deploy && \
  mix phx.digest priv/static && \
  mix download_country_database && \
  # https://hexdocs.pm/sentry/Sentry.Sources.html#module-source-code-storage
  mix sentry_recompile

WORKDIR /app
COPY rel rel

# Build Plausible Binary
RUN mix release plausible

# Get build artifacts
FROM scratch AS release

# Redefine environment variables
ARG MIX_ENV=small
ENV MIX_ENV=$MIX_ENV

# Copy release binaries from the buildcontainer to release target
COPY --from=buildcontainer /app/_build/${MIX_ENV}/rel/plausible /
COPY --chmod=755 ./rel/docker-entrypoint.sh /entrypoint.sh

# Build process is now complete. Retreive binaries by setting
# the `--output` and `--target=release` flags. (see `build.sh`)