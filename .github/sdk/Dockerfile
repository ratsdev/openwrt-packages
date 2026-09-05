# OpenWrt SDK plus host clang (vianes build.rs compiles bpf/kern/vianes.c).
ARG ARCH=x86_64-25.12.5
FROM docker.io/openwrt/sdk:${ARCH}

USER root

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		ca-certificates \
		clang \
	&& rm -rf /var/lib/apt/lists/*

COPY build.sh /build.sh
RUN chmod +x /build.sh

ENTRYPOINT ["/build.sh"]
