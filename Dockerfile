FROM alpine:edge AS builder
RUN apk update && apk upgrade
RUN apk add --no-cache crystal shards libc-dev \
    yaml-dev libxml2-dev sqlite-dev zlib-dev openssl-dev \
    sqlite-static zlib-static openssl-libs-static git curl

RUN git clone https://github.com/omarroth/invidious
WORKDIR /invidious
RUN shards update && shards install
RUN curl -Lo /etc/apk/keys/omarroth.rsa.pub https://github.com/omarroth/boringssl-alpine/releases/download/1.1.0-r0/omarroth.rsa.pub && \
    curl -Lo boringssl-dev.apk https://github.com/omarroth/boringssl-alpine/releases/download/1.1.0-r0/boringssl-dev-1.1.0-r0.apk && \
    curl -Lo lsquic.apk https://github.com/omarroth/lsquic-alpine/releases/download/2.6.3-r0/lsquic-2.6.3-r0.apk && \
    tar -xf boringssl-dev.apk && \
    tar -xf lsquic.apk \
    mv ./usr/lib/libcrypto.a ./lib/lsquic/src/lsquic/ext/libcrypto.a && \
    mv ./usr/lib/libssl.a ./lib/lsquic/src/lsquic/ext/libssl.a && \
    mv ./usr/lib/liblsquic.a ./lib/lsquic/src/lsquic/ext/liblsquic.a

RUN crystal build ./src/invidious.cr \
    --static --warnings all --error-on-warnings \
# TODO: Remove next line, see https://github.com/crystal-lang/crystal/issues/7946
    -Dmusl \
    --link-flags "-lxml2 -llzma"

COPY config.yml /invidious/config/config.yml
COPY init.sql /invidious/config/init.sql
EXPOSE 3000

CMD [ "/invidious/invidious" ]