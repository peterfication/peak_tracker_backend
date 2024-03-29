# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20230202-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.14.3-erlang-25.2.3-debian-bullseye-20230202-slim
#
# See https://hexdocs.pm/elixir/1.15.7/compatibility-and-deprecations.html
ARG ELIXIR_VERSION=1.15.7
ARG OTP_VERSION=26.1.2
ARG ALPINE_VERSION=3.18.4

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-alpine-${ALPINE_VERSION}"
ARG RUNNER_IMAGE="alpine:${ALPINE_VERSION}"

# The version is used for Sentry release tracking
ARG VERSION=default

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apk update && apk add build-base linux-headers git && rm -rf /var/cache/apk/*

# See https://stackoverflow.com/questions/52894632/cannot-install-pycosat-on-alpine-during-dockerizing
RUN echo "#include <unistd.h>" > /usr/include/sys/unistd.h

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets

# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

# Re-declare args that are needed in the runner image
ARG VERSION

RUN apk update && apk add libstdc++ openssl ncurses-dev musl-locales && rm -rf /var/cache/apk/*

# Set the locale
# RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"

# Run and own the application files as a non-root user for security
RUN adduser -D web

RUN chown web /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=web:root /app/_build/${MIX_ENV}/rel/peak_tracker ./

# Copy the release and start script
COPY release.sh /release.sh
COPY start.sh /start.sh

ENV VERSION=${VERSION}
ENV SENTRY_RELEASE=${VERSION}

CMD ["/start.sh"]

# Appended by flyctl
ENV ECTO_IPV6 true
ENV ERL_AFLAGS "-proto_dist inet6_tcp"
