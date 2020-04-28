ARG DOCKER_BASE=ubuntu:18.04

FROM ${DOCKER_BASE} AS data-recoverer

RUN apt-get update \
    && apt-get install --yes --no-install-recommends git ca-certificates
RUN git clone --branch=master --depth 1 https://github.com/wirepas/gateway.git

FROM ${DOCKER_BASE}

ENV WM_USER=wirepas
ENV WM_HOME=/home/${WM_USER}

RUN apt-get update && \
    apt-get install -y dbus && \
    rm -rf /var/lib/apt/lists/*

COPY --from=data-recoverer /gateway/sink_service/com.wirepas.sink.conf /etc/dbus-1/system.d/
COPY entry-point.sh /etc/init/

RUN mkdir -p /var/run/dbus

RUN groupadd --gid 1000 ${WM_USER} \
    && useradd --uid 1000 --gid 1000 --home-dir ${WM_HOME} ${WM_USER}

ENTRYPOINT ["/etc/init/entry-point.sh"]
CMD ["start"]

HEALTHCHECK \
    --interval=5s \
    --timeout=3s \
    --start-period=5s \
    --retries=1 \
    CMD [ -S /var/run/dbus/system_bus_socket ] && \
        [ -f /var/run/dbus/pid ] || \
        exit 1
