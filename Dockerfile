FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    nginx \
    build-essential \
    autoconf \
    automake \
    libtool \
    git \
    pkg-config \
    wget \
    gengetopt \
    libglib2.0-dev \
    libnice-dev \
    libjansson-dev \
    libssl-dev \
    libmicrohttpd-dev \
    libcurl4-openssl-dev

RUN cd /tmp \
    && wget -O libsrtp-1.6.0.tar.gz \
        https://github.com/cisco/libsrtp/archive/v1.6.0.tar.gz \
    && tar xvf libsrtp-1.6.0.tar.gz \
    && cd libsrtp-1.6.0 \
    && ./configure \
    && make && make install \
    && cd -

RUN cd /tmp \
    && wget -O janus-gateway-0.2.6.tar.gz \
       https://github.com/meetecho/janus-gateway/archive/v0.2.6.tar.gz \
    && tar xvf janus-gateway-0.2.6.tar.gz \
    && cd janus-gateway-0.2.6 \
    && ./autogen.sh \
    && ./configure \
        --disable-all-plugins \
        --enable-plugin-streaming \
        --enable-rest \
        --disable-websockets \
        --disable-rabbitmq \
        --disable-mqtt \
        --disable-unix-sockets \
    && make && make install \
    && cd -

RUN rm -rf /usr/local/etc/janus/\*

COPY janus.cfg /usr/local/etc/janus/
COPY janus.plugin.streaming.cfg /usr/local/etc/janus/
COPY janus.transport.http.cfg /usr/local/etc/janus/
COPY nginx.conf /etc/nginx/
COPY respawn-on-error /usr/local/bin/respawn-on-error

EXPOSE 8088
EXPOSE 8080

CMD /etc/init.d/nginx start && respawn-on-error janus
