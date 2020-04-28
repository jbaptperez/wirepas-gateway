# sink-service

This image holds only the Wirepas sink service, which is different from the
official Wirepas image.

The images runs the `wirepas` user to access the sink device with minimum
privileges for security.

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
    jbaptperez/wirepas-d-bus-service:latest
```

Then, assuming you are configuring the sink 0 and the *dev* node entry is
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

The container accesses the shared Unix socket via the `d-bus-volume`
volume using the `wirepas` user (UID and GID = 1000).

Note the `wirepas` user belongs to the `dialout` group (GID = 20).
The host sink dev node should belong to this group for a proper access in the
container.

You can then stop the containers:

```bash
docker stop sink-service-0
docker stop d-bus-service
```

Once the docker container are stopped, just suppress the containers and the
volume:

```bash
docker rm sink-service-0
docker rm d-bus-service
docker volume rm wirepas-d-bus-service
```

Note that this image can easily be integreated within a Docker compose set-up.
