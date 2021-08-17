
FROM alpine:edge AS liblsquic-builder
WORKDIR /src

RUN apk add --no-cache git build-base git apk-tools abuild cmake go perl linux-headers
RUN git clone https://github.com/iv-org/invidious

RUN abuild-keygen -a -n && \
    cp /root/.abuild/-*.rsa.pub /etc/apk/keys/

RUN mkdir /src/boringssl && cp /src/invidious/docker/APKBUILD-boringssl /src/boringssl/APKBUILD

RUN cd /src/boringssl && abuild -F -r && cd ..

RUN apk add --repository /root/packages/src boringssl boringssl-dev boringssl-static

RUN apk add --no-cache zlib-dev zlib-static libevent-dev libevent-static

RUN mkdir /src/lsquic && cp /src/invidious/docker/APKBUILD-lsquic /src/lsquic/APKBUILD
RUN cd /src/lsquic && abuild -F -r && cd ..

RUN apk add --repository /root/packages/src lsquic-static

RUN mkdir tmp && cd tmp && \
    ar -x /usr/lib/libssl.a && \
    ar -x /usr/lib/libcrypto.a && \
    ar -x /usr/lib/liblsquic.a && \
    ar rc liblsquic.a *.o && \
    strip --strip-unneeded liblsquic.a && \
    ranlib liblsquic.a && \
    cp liblsquic.a /root/liblsquic.a && \
    cd .. && rm -rf tmp

FROM crystallang/crystal:1.1.1-alpine AS builder
RUN apk add --no-cache curl sqlite-static git yaml-static
RUN git clone https://github.com/iv-org/invidious
WORKDIR /invidious
RUN shards update && shards install
COPY --from=liblsquic-builder /root/liblsquic.a ./lib/lsquic/src/lsquic/ext/liblsquic.a
RUN crystal spec \
    --warnings all \
    --link-flags "-lxml2 -llzma"
RUN crystal build ./src/invidious.cr \
    --static --warnings all \
    --link-flags "-lxml2 -llzma"

FROM alpine:latest
RUN apk add --no-cache librsvg ttf-opensans
WORKDIR /invidious
RUN addgroup -g 1000 -S invidious && \
    adduser -u 1000 -S invidious -G invidious
COPY --chown=invidious config.yml ./config/config.yml
COPY --chown=invidious init.sql ./config/init.sql
COPY --from=builder /invidious/assets/ ./assets/
COPY --from=builder /invidious/locales/ ./locales/
COPY --from=builder /invidious/invidious .

EXPOSE 3000
USER invidious
CMD [ "/invidious/invidious" ]
