ARG DOCKER_BASE=ubuntu:18.04

FROM ${DOCKER_BASE} AS data-recoverer

RUN apt-get update \
    && apt-get install --yes --no-install-recommends git ca-certificates
RUN git clone --branch=master --depth 1 https://github.com/wirepas/tutorials.git

FROM eclipse-mosquitto:1.6

ENV MOSQUITTO_CONFIGURATION_DIR="/mosquitto/config"
ENV MOSQUITTO_CONFIGURATION_FILE="${MOSQUITTO_CONFIGURATION_DIR}/mosquitto.conf"
ENV MOSQUITTO_PASSWORD_FILE="${MOSQUITTO_CONFIGURATION_DIR}/passwd"
ENV MOSQUITTO_ACL_FILE="${MOSQUITTO_CONFIGURATION_DIR}/acl"

COPY --from=data-recoverer /tutorials/mosquitto/*.template "${MOSQUITTO_CONFIGURATION_DIR}/"

# Replace entrypoint set by mosquitto
# see https://github.com/docker-library/repo-info/blob/master/repos/eclipse-mosquitto/local/1.6.md
COPY --from=data-recoverer /tutorials/mosquitto/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

CMD mosquitto -c ${MOSQUITTO_CONFIGURATION_FILE}

ENTRYPOINT ["/docker-entrypoint.sh"]
