FROM alpine:3.19

RUN apk add --no-cache \
    ncurses \
    file \
    imagemagick \
    ffmpeg \
    perl-image-exiftool \
    curl \
    unzip \
    openssl \
    ca-certificates \
    postgresql-client

ARG AKKOMA_BRANCH=stable
ARG AKKOMA_FLAVOUR=amd64-musl

RUN adduser -S -h /opt/akkoma -s /bin/sh akkoma

RUN curl -fsSL \
    "https://akkoma-updates.s3-website.fr-par.scw.cloud/${AKKOMA_BRANCH}/akkoma-${AKKOMA_FLAVOUR}.zip" \
    -o /tmp/akkoma.zip && \
    unzip /tmp/akkoma.zip -d /tmp/ && \
    mv /tmp/release/* /opt/akkoma/ && \
    rm -rf /tmp/release /tmp/akkoma.zip && \
    chown -R akkoma /opt/akkoma

RUN mkdir -p /var/lib/akkoma/uploads \
             /var/lib/akkoma/static \
             /var/lib/akkoma/static/frontends \
             /etc/akkoma && \
    chown -R akkoma /var/lib/akkoma /etc/akkoma

USER akkoma
WORKDIR /opt/akkoma

EXPOSE 4000

ENV PLEROMA_CONFIG_PATH=/etc/akkoma/config.exs
ENV ERL_EPMD_ADDRESS=127.0.0.1
# Prevent BEAM VM busywait in containers (Akkoma issue #832)
ENV ELIXIR_ERL_OPTIONS="+sbwt none +sbwtdcpu none +sbwtdio none"

ENTRYPOINT ["./bin/pleroma"]
CMD ["start"]
