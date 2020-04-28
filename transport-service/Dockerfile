ARG DOCKER_BASE=ubuntu:18.04

FROM ${DOCKER_BASE} AS data-recoverer

RUN apt-get update \
    && apt-get install --yes --no-install-recommends git ca-certificates
RUN git clone --branch=master --depth 1 https://github.com/wirepas/gateway.git \
    && rm -rf /gateway/.git

FROM ${DOCKER_BASE}

ARG DOCKER_BASE
ARG LXGW_SERVICES_HASH
ARG WM_TRANSPORT_PKG

ENV WM_USER=wirepas
ENV WM_HOME=/home/${WM_USER}
ENV SERVICE_HOME="${WM_HOME}/gateway"
ENV TRANSPORT_SERVICE="${SERVICE_HOME}/transport_service"
ENV WM_TRANSPORT_PKG=${WM_TRANSPORT_PKG:-"${TRANSPORT_SERVICE}/wirepas_gateway-*.tar.gz"}

RUN groupadd --gid 1000 ${WM_USER} \
    && useradd --uid 1000 --gid 1000 --home-dir ${WM_HOME} ${WM_USER}

RUN apt-get update \
    && apt-get install --yes software-properties-common \
    && add-apt-repository --yes ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install --yes --no-install-recommends \
       gcc \
       g++ \
       libsystemd-dev \
       python3.7 \
       python3.7-dev \
       python3-setuptools \
       python3-pip \
       python3-gi \
       python3-gi-cairo \
    && rm -rf /var/lib/apt

COPY --from=data-recoverer /gateway/container/common/docker-entrypoint.sh /usr/local/bin/
COPY --from=data-recoverer /gateway/python_transport/ /app_build/python_transport/
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 10 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 100 \
    && update-alternatives --set python3 /usr/bin/python3.7 \
    && cd /usr/lib/python3/dist-packages/gi \
    && for f in $(find . -name '*36*.so'); do ln -s $f $(echo $f | sed 's/36/37/'); done
RUN cd /app_build/python_transport \
    && python3 -m pip install --no-cache-dir --upgrade pip \
    && python3 -m pip install virtualenv \
    && python3 -m pip install wheel setuptools
RUN cd /app_build/python_transport \
    && ./utils/generate_wheel.sh
RUN mkdir -vp "${TRANSPORT_SERVICE}/" \
    && cp -v /app_build/python_transport/requirements.txt "${TRANSPORT_SERVICE}/" \
    && cp -v /app_build/python_transport/dist/* "${TRANSPORT_SERVICE}/" \
    && echo "LXGW_SERVICES_HASH=${LXGW_SERVICES_HASH}" >> "${SERVICE_HOME}/manifest" \
    && echo "LXGW_VERSION=$(< wirepas_gateway/__about__.py awk '/__version__/{print $NF}'| tr -d '\"')" >> "${SERVICE_HOME}/manifest" \
    && python3 -m pip install --no-cache-dir -r "${TRANSPORT_SERVICE}/requirements.txt" \
    && python3 -m pip install --no-cache-dir ${WM_TRANSPORT_PKG}
RUN rm -rf "${WM_HOME}/.cache" \
    && rm -rf /app_build \
    && chown -R "${WM_USER}":"${WM_USER}" "${WM_HOME}"


USER ${WM_USER}

CMD ["wm-gw"]
