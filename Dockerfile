FROM alpine:3.9 as prep
RUN apk add --no-cache git
RUN git clone --recurse-submodules --depth 1 --single-branch https://github.com/SoftEtherVPN/SoftEtherVPN.git /usr/local/src/SoftEtherVPN

FROM debian:10 as build
RUN apt update && \
    apt -yq install \
      cmake \
      gcc \
      g++ \
      libncurses5-dev \
      libreadline-dev \
      libsodium-dev \
      libssl-dev \
      make \
      pkg-config \
      zlib1g-dev \
      file \
      zip
COPY --from=prep /usr/local/src /usr/local/src
RUN mkdir -pv /logs && \
    mkdir -pv /config
RUN cd /usr/local/src/SoftEtherVPN && \
    sed 's/StrCmpi(region, "JP") == 0 || StrCmpi(region, "CN") == 0/false/' -i src/Cedar/Server.c && \
    CMAKE_FLAGS="-DSE_LOGDIR=/logs -DSE_DBDIR=/config" ./configure && \
    make -C build && \
    make -C build package
RUN mkdir -pv /tmp/softether-pkgs && \
    cp /usr/local/src/SoftEtherVPN/build/softether-*.deb /tmp/softether-pkgs
# RUN cp /usr/local/lib/*.so /usr/lib

FROM debian:10-slim
# Config file: /config/vpn_server.config
VOLUME /config
VOLUME /logs
# PORTS
EXPOSE 443/tcp
# 5555 = SoftEther & web interface
EXPOSE 5555/tcp
# 500, 4500 & 1701 = L3TP/IPsec
EXPOSE 500/udp 4500/udp 1701/udp
# 1194 & 992 = OpenVPN
EXPOSE 1194/udp 1194/tcp 992/tcp
RUN apt update && \
    apt install -yq --no-install-recommends \
      libncurses6 \
      libreadline7 \
      libssl1.1 \
      iptables \
      zlib1g
COPY --from=build /tmp/softether-pkgs /tmp/softether-pkgs
RUN dpkg -i /tmp/softether-pkgs/*.deb
# ENTRYPOINT [ "/usr/local/libexec/softether/vpnserver" ]
# CMD [ "vpnserver", "start --foreground" ]
