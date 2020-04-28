# mosquitto-service
Multi-architecture version of the wirepas/mosquitto image

To start a container which listens to the host ports 1883 (MQTT) and 9001
(WebSocket), allowing connection by the `mqttuser` user using `mqttpassword`
password:

```bash
docker run \
    --detach=true \
    --name=mosquitto-service \
    --publish 1883:1883 \
    --publish 9001:9001 \
    jbaptperez/wirepas-mosquitto-service:latest
```

Username and password can be changed thanks to the `MQTT_USERNAME` and
`MQTT_PASSWORD` environment variables:

```bash
docker run \
    --detach=true \
    --name=mosquitto-service \
    --env=MQTT_USERNAME=mqttuser \
    --env=MQTT_PASSWORD=mqttpassword \
    --publish 1883:1883 \
    --publish 9001:9001 \
    jbaptperez/wirepas-mosquitto-service:latest
```

Other environment variables can alter the resulting configuration file created
on container start.

| Environment variable              | Default value                | Required |
|-----------------------------------|------------------------------|:--------:|
| MQTT_USERNAME                     | ${WM_SERVICES_MQTT_USERNAME} |     x    |
| MQTT_PASSWORD                     | ${WM_SERVICES_MQTT_PASSWORD} |     x    |
| MQTT_PERSISTENCE                  | true                         |          |
| MQTT_PERSISTENCE_LOCATION         | "/mosquitto/data/"           |          |
| MQTT_SYS_INTERVAL                 | 300                          |          |
| MQTT_AUTOSAVE_INTERVAL            | 60                           |          |
| MQTT_QUEUE_QOS0_MESSAGES          | true                         |          |
| MQTT_MAX_QUEUED_MESSAGES          | 1000                         |          |
| MQTT_MAX_INFLIGHT_MESSAGES        | 1000                         |          |
| MQTT_ALLOW_ANONYMOUS              | false                        |          |
| MQTT_PASSWORD_FILE                | /mosquitto/config/passwd     |          |
| MQTT_CONNECTION_MESSAGES          | true                         |          |
| MQTT_LOG_DESTINATION              | stdout                       |          |
| MQTT_PERSISTENT_CLIENT_EXPIRATION | 1h                           |          |
| MQTT_LISTEN                       | 1883                         |          |
| MQTT_WS_LISTENER                  | 9001                         |          |


You can then stop the container:

```bash
docker stop mosquitto-service
```

Once the docker container is stopped, just suppress it:

```bash
docker rm mosquitto-service
```

Note that this image can easily be integreated within a Docker compose set-up.
