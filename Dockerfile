FROM golang:1.26-alpine3.22 AS build

ARG VERSION="untracked"

WORKDIR /webdav/

COPY ./go.mod ./
COPY ./go.sum ./
RUN go mod download

RUN mkdir -p -m 1777 /rootfs/tmp

COPY . /webdav/
RUN go build -o main -trimpath -ldflags="-s -w -X 'github.com/hacdias/webdav/v5/cmd.version=$VERSION'" .

# Alpine instead of scratch, so the container has a shell and basic tools
# (ls, sh) for container file browsers and `docker exec`.
FROM alpine:3.22

COPY --from=build /webdav/main /bin/webdav
COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

EXPOSE 6065

ENTRYPOINT [ "docker-entrypoint.sh" ]
