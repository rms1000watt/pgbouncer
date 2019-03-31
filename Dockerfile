FROM ubuntu:latest AS build_stage
RUN apt update -y \
    && apt install -y git python python-pip automake libtool m4 autoconf libevent-dev openssl libssl-dev pkg-config curl build-essential\
    && pip install docutils \
    && curl -L -o pandoc-2.7.1.tar.gz https://github.com/jgm/pandoc/releases/download/2.7.1/pandoc-2.7.1-linux.tar.gz \
    && tar -zxvf pandoc-2.7.1.tar.gz \
    && mv pandoc-2.7.1/bin/* /usr/bin \
    && git clone https://github.com/pgbouncer/pgbouncer.git src \
    && cd /bin \
    && ln -s ../usr/bin/rst2man.py rst2man \
    && cd /src \
    && mkdir /pgbouncer \
    && git submodule init \
    && git submodule update \
    && ./autogen.sh \
    && ./configure --prefix=/pgbouncer --with-libevent=/usr/lib \
    && make \
    && make install \
    && ls -R /pgbouncer

FROM alpine:latest
RUN apk --update add libevent openssl c-ares
ADD entrypoint.sh /
COPY --from=build_stage /pgbouncer /pgbouncer
ENTRYPOINT ["/entrypoint.sh"]
