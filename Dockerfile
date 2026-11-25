ARG MATTERMOST_VERSION=11.7.15

FROM --platform=$BUILDPLATFORM golang:1.26.11-bookworm AS build
ARG MATTERMOST_VERSION
ARG BUILD_HASH
ARG TARGETARCH

COPY . /src

WORKDIR /src/server
RUN go work init . ./public

RUN model=github.com/mattermost/mattermost/server/public/model \
  && CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH go build -o /out/ -buildvcs=false -trimpath -tags production \
    -ldflags "-X '$model.BuildNumber=${MATTERMOST_VERSION}' \
              -X '$model.BuildDate=$(date -u)' \
              -X '$model.BuildHash=${BUILD_HASH}' \
              -X '$model.BuildHashEnterprise=none' \
              -X '$model.BuildEnterpriseReady=false'" \
    ./cmd/mattermost ./cmd/mmctl

FROM mattermost/mattermost-team-edition:${MATTERMOST_VERSION} AS upstream

FROM debian:12-slim AS rootfs
COPY --from=upstream / /rootfs
COPY --from=build --chown=2000:2000 /out/mattermost /out/mmctl /rootfs/mattermost/bin/
RUN rm -rf /rootfs/mattermost/prepackaged_plugins/* \
  && apt-get update \
  && cd /tmp && apt-get download libssl3 \
  && dpkg-deb -x libssl3_*.deb /rootfs \
  && dpkg-deb -f libssl3_*.deb > /rootfs/var/lib/dpkg/status.d/libssl3 \
  && dpkg-deb --ctrl-tarfile libssl3_*.deb | tar -xO ./md5sums > /rootfs/var/lib/dpkg/status.d/libssl3.md5sums

FROM scratch
COPY --from=rootfs /rootfs /
ENV PATH=/mattermost/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    MM_SERVICESETTINGS_ENABLELOCALMODE=true \
    MM_INSTALL_TYPE=docker
USER mattermost
WORKDIR /mattermost
EXPOSE 8065 8067 8074 8075
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]
HEALTHCHECK --interval=30s --timeout=10s CMD ["/mattermost/bin/mmctl", "system", "status", "--local"]
CMD ["/mattermost/bin/mattermost"]

RUN ["/mattermost/bin/mmctl", "config", "subpath", "--assets-dir", "/mattermost/client", "--path", "/chat"]
