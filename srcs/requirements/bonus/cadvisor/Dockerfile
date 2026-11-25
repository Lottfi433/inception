FROM debian:12

ARG TARGETARCH

RUN apt-get update \
    && apt-get install -y wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O /usr/bin/cadvisor \
    https://github.com/google/cadvisor/releases/download/v0.60.5/cadvisor-v0.60.5-linux-${TARGETARCH} \
    && chmod +x /usr/bin/cadvisor

CMD ["/usr/bin/cadvisor", "--port=8080", "--url_base_prefix=/cadvisor"]

