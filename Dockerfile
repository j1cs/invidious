FROM crystallang/crystal:0.36.1-alpine AS builder
RUN apk add --no-cache curl sqlite-static git
RUN git clone https://github.com/iv-org/invidious
WORKDIR /invidious
RUN shards update && shards install && \
    curl -Lo ./lib/lsquic/src/lsquic/ext/liblsquic.a https://github.com/iv-org/lsquic-static-alpine/releases/download/v2.18.1/liblsquic.a
RUN crystal build ./src/invidious.cr --release \
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
