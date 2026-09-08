# OpenWrt SDK plus host clang (vianes build.rs compiles bpf/kern/vianes.c).
ARG ARCH=x86_64-25.12.5
FROM docker.io/openwrt/sdk:${ARCH}

USER root

# bullseye EOL 2026-08-31: security InRelease is no longer re-signed, skip its Valid-Until check.
RUN apt-get -o Acquire::Check-Valid-Until=false update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		ca-certificates \
		clang \
	&& rm -rf /var/lib/apt/lists/*

COPY build.sh /build.sh
RUN chmod +x /build.sh

ENTRYPOINT ["/build.sh"]
