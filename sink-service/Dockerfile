ARG DOCKER_BASE=ubuntu:18.04

FROM ${DOCKER_BASE} AS data-recoverer

RUN apt-get update \
    && apt-get install --yes --no-install-recommends git ca-certificates
RUN git clone https://github.com/wirepas/gateway.git --branch=v1.3.0 --depth 1 \
    && git clone https://github.com/wirepas/c-mesh-api.git --branch=v1.3.0 --depth 1 \
    && rm -rf /gateway/.git \
    && rm -rf /c-mesh-api/.git

FROM ${DOCKER_BASE} AS app-builder

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        make \
        gcc \
        libc6-dev \
        libsystemd-dev
COPY --from=data-recoverer /gateway/sink_service /app_build/sink_service/
COPY --from=data-recoverer /c-mesh-api /app_build/sink_service/c-mesh-api/
RUN make -C /app_build/sink_service


FROM ${DOCKER_BASE}

ENV WM_USER=wirepas
ENV WM_HOME=/home/${WM_USER}

RUN groupadd --gid 1000 ${WM_USER} \
    && useradd --uid 1000 --gid 1000 --home-dir ${WM_HOME} --groups dialout ${WM_USER}

COPY --from=app-builder /app_build/sink_service/build/sinkService /usr/local/bin/

USER ${WM_USER}

CMD ["sinkService"]
