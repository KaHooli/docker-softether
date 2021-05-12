FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt -yq --no-install-recommends install \
      git \
      ca-certificates \
      cmake \
      gcc \
      g++ \
      make \
      libncurses5-dev \
      libssl-dev \
      libsodium-dev \
      libreadline-dev \
      zlib1g-dev \
      pkg-config
# other apt packages recommended by above install: patch less ssh-client manpages manpages-dev libfile-fcntllock-perl liblocale-gettext-perl xz-utils libglib2.0-data shared-mime-info xdg-user-dirs krb5-locales publicsuffix libsasl2-modules netbase

RUN mkdir -pv /logs && mkdir -pv /config

# Cloning SoftEther VPN source code
RUN git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git /SoftEtherVPN
RUN cd /SoftEtherVPN && \
    git submodule init && \
    git submodule update

# Compiling SoftEther VPN server
RUN cd /SoftEtherVPN && CMAKE_FLAGS="-DSE_LOGDIR=/logs -DSE_DBDIR=/config" ./configure
RUN cd /SoftEtherVPN && make -C build
RUN cd /SoftEtherVPN && make -C build install && cd /
# Line below fixes error about missing libcedar.so
RUN cp /usr/local/lib/*.so /usr/lib

# RUN cd /opt/vpnserver && make i_read_and_agree_the_license_agreement

# COPY files/* /opt/
# RUN chmod 755 /opt/*.sh

EXPOSE 5555

# VOLUMES

# Config file: /usr/local/libexec/softether/vpnserver/vpn_server.config

ENTRYPOINT /bin/bash
# ENTRYPOINT /opt/start.sh
