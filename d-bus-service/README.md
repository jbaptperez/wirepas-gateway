# d-bus-service

To start the container:

Build first a volume used to share the D-Bus socket:

```bash
docker volume create d-bus-volume
```

Then start the container:

```bash
docker run \
    --detach=true \
    --name=d-bus-service \
    --volume=d-bus-volume:/var/run/dbus \
    jbaptperez/wirepas-d-bus-service:latest \
    start
```

Any other container can access the shared Unix socket via the `d-bus-volume`
volume using the `wirepas` user (UID and GID = 1000).

The socket name within the `d-bus-volume` volume is: `system_bus_socket`.

You can then stop the containers:

```bash
docker stop d-bus-service
```

Once the docker container is stopped, just suppress it and the volume:

```bash
docker rm d-bus-service
docker volume rm d-bus-volume
```


Note that this image can easily be integreated within a Docker compose set-up.
