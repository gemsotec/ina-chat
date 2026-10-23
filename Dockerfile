ARG MATTERMOST_VERSION=11.7.14

FROM --platform=$BUILDPLATFORM golang:1.26.10-bookworm AS build
ARG MATTERMOST_VERSION
ARG BUILD_HASH
ARG TARGETARCH

COPY . /src

WORKDIR /src/server
RUN go work init . ./public

RUN model=github.com/mattermost/mattermost/server/public/model \
  && CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH go build -o /out/mattermost -buildvcs=false -trimpath -tags production \
    -ldflags "-X '$model.BuildNumber=${MATTERMOST_VERSION}' \
              -X '$model.BuildDate=$(date -u)' \
              -X '$model.BuildHash=${BUILD_HASH}' \
              -X '$model.BuildHashEnterprise=none' \
              -X '$model.BuildEnterpriseReady=false'" \
    ./cmd/mattermost

FROM mattermost/mattermost-team-edition:${MATTERMOST_VERSION}
COPY --from=build --chown=2000:2000 /out/mattermost /mattermost/bin/mattermost

RUN ["/mattermost/bin/mmctl", "config", "subpath", "--assets-dir", "/mattermost/client", "--path", "/chat"]
