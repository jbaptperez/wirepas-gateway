# transport-service

Multi-architecture image of Wirepas transport service

This image holds only the Wirepas transport service, which is different from the
official Wirepas image.

The images runs the `wirepas` user to operate with minimum privileges for
security.

To start the container, build first a volume used to share the D-Bus socket:

```bash
docker volume create d-bus-volume
```

Run then a D-Bus daemon container, e.g. using the
[jbaptperez/wirepas-d-bus-service](https://hub.docker.com/repository/docker/jbaptperez/wirepas-d-bus-service)
image:

```bash
docker run \
    --detach=true \
    --name=d-bus-service \
    --volume=d-bus-volume:/var/run/dbus \
    jbaptperez/wirepas-d-bus-service:latest \
    start
```

Then run a sink service container, e.g. using the
[jbaptperez/wirepas-sink-service](https://hub.docker.com/repository/docker/jbaptperez/wirepas-sink-service)
image.
This assumes you are configuring the sink 0 and the *dev* node entry is
located at `/dev/ttyUSB0`, you can start the container the following way:

```bash
docker run \
    --name=sink-service-0 \
    --detach=true \
    --env=WM_GW_SINK_ID=0 \
    --env=WM_GW_SINK_UART_PORT=/dev/ttyUSB0 \
    --env=WM_GW_SINK_BITRATE=125000 \
    --volume=d-bus-volume:/var/run/dbus \
    --device=/dev/ttyUSB0:/dev/ttyUSB0 \
    jbaptperez/wirepas-sink-service:latest
```

Then build a network for transport and mosquitto service communication:

```bash
docker network create -d bridge gateway-network
```

Then run a MQTT container, e.g. using the
[jbaptperez/wirepas-mosquitto-service](https://hub.docker.com/repository/docker/jbaptperez/wirepas-mosquitto-service)
image:

```bash
docker run \
    --detach=true \
    --name=mosquitto-service \
    --env=MQTT_USERNAME=mqttuser \
    --env=MQTT_PASSWORD=mqttpassword \
    --network=gateway-network \
    --publish 1883:1883 \
    --publish 9001:9001 \
    jbaptperez/wirepas-mosquitto-service:latest
```

Finally, you can run a Wirepas transport service container.


```bash
docker run \
    --detach=true \
    --name=transport-service \
    --env=WM_GW_MODEL=lxgw \
    --env=WM_GW_VERSION=gitbuild \
    --env=WM_GW_IGNORED_ENDPOINTS_FILTER= \
    --env=WM_GW_WHITENED_ENDPOINTS_FILTER= \
    --env=WM_SERVICES_MQTT_HOSTNAME=mosquitto-service \
    --env=WM_SERVICES_MQTT_PORT=1883 \
    --env=WM_SERVICES_MQTT_USERNAME=mqttuser \
    --env=WM_SERVICES_MQTT_PASSWORD=mqttpassword \
    --env=WM_SERVICES_MQTT_CA_CERTS=/etc/my-tls-file \
    --env=WM_SERVICES_MQTT_ALLOW_UNTRUSTED=true \
    --env=WM_SERVICES_MQTT_FORCE_UNSECURE=true \
    --env=PYTHONUNBUFFERED=true \
    --volume=d-bus-volume:/var/run/dbus \
    --network=gateway-network \
    jbaptperez/wirepas-transport-service:latest
```

The container accesses the shared Unix socket via the `d-bus-volume`
volume using the `wirepas` user (UID and GID = 1000).

You can then stop the containers:

```bash
docker stop transport-service
docker stop mosquitto-service
docker stop sink-service-0
docker stop d-bus-service
```

Once the docker container are stopped, just suppress the containers, the network
and the volume

```bash
docker rm transport-service
docker rm mosquitto-service
docker network rm gateway-network
docker rm sink-service-0
docker rm d-bus-service
docker volume rm d-bus-volume
```

Note that this image can easily be integreated within a Docker compose set-up.
