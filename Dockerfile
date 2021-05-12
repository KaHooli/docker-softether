FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt -yq --no-install-recommends install git ca-certificates cmake gcc g++ make libncurses5-dev libssl-dev libsodium-dev libreadline-dev zlib1g-dev pkg-config
# other apt packages recommended by above install: patch less ssh-client netbase
RUN git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git
RUN cd SoftEtherVPN
RUN git submodule init && git submodule update
RUN ./configure
RUN make -C build
RUN make -C build install



RUN cd /opt/vpnserver && make i_read_and_agree_the_license_agreement

COPY files/* /opt/
RUN chmod 755 /opt/*.sh

EXPOSE 5555

ENTRYPOINT /bin/bash
# ENTRYPOINT /opt/start.sh
