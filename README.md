# wirepas-gateway-compose

Runs a wirepas gateway from a Docker compose file (MQTT broker included).

First, create a `.env` file from the template:

```bash
cp .env-template .env
```

Adapt the environment variables located in `.env`:

```bash
vi .env
```

Then create the dedicated D-Bus volume, network and containers and start the
containers using the following command:

```bash
docker-compose up -d
```

You can then connect to the MQTT broker with the following default credentials:

* Host: `localhost`
* Port: `1883`
* Username: `mqttuser`
* Password: `mqttpassword`


When you are done, stop containers and remove dedicated containers, network and
D-Bus volume using the following command:

```bash
docker-compose down
```
