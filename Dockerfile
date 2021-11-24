#
# Dockerfile for shadowsocks-libev
#

FROM alpine:3.10
MAINTAINER EasyPi Software Foundation


ENV SS_URL https://github.com/shadowsocks/shadowsocks-libev/archive/v3.3.5.tar.gz
ENV SS_DIR shadowsocks-libev-3.3.5

RUN set -ex \
    && apk add --no-cache c-ares \
                          libcrypto1.1 \
                          libev \
                          libsodium \
                          mbedtls \
                          pcre \
    && apk add --no-cache \
               --virtual TMP autoconf \
                             automake \
                             build-base \
                             c-ares-dev \
                             curl \
                             gettext-dev \
                             libev-dev \
                             libsodium-dev \
                             libtool \
                             linux-headers \
                             mbedtls-dev \
                             openssl-dev \
                             pcre-dev \
                             tar \
    && curl -sSL $SS_URL | tar xz \
    && cd $SS_DIR \
        && curl -sSL https://github.com/shadowsocks/ipset/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libipset \
        && curl -sSL https://github.com/shadowsocks/libcork/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libcork \
        && curl -sSL https://github.com/shadowsocks/libbloom/archive/master.tar.gz | tar xz --strip 1 -C libbloom \
        && ./autogen.sh \
        && ./configure --disable-documentation \
        && make install \
        && cd .. \
        && rm -rf $SS_DIR \
    && apk del TMP \
    && rm -f /usr/bin/ss-local

COPY ss-local /usr/bin/
COPY config.json /tmp/

EXPOSE 1080/tcp
EXPOSE 1080/udp

CMD ss-local -c /tmp/config.json