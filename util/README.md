# Utilities

## Fixed sink serial paths with dedicated udev rules

The `99-wirepas-sinks.rules` file contains predefined udev rules that add
fixed sink paths within the `/dev` directory.
The following name convention is used:

````
/dev/serial/by-wirepas-sink-id/[x]
````
where [x] is the sink ID.

The `99-wirepas-sinks.rules` contains rules for:
* Raspberry Pi 3B+ (default)
* Raspberry Pi 2B+ (commented)
* Dell Vostro  (commented)

Copy this file into the `/etc/udev/rules.d/` directory of the host, adapt
comments to your configuration and either use the `udevadm trigger` command or
reboot your host system to make the rules applied.


## Docker multi-architecture builds

Docker is integrating the `buildx` CLI plugin since version 19.03.
This plugin enhances the Docker image building process.
Among the new functionalities, it becomes possible and pretty easy to build
images for different architectures than the host one.

However, the the `buildx` plugin is still experimental and needs to be enabled.
Moreover, some extra-steps have to be done to make it operational, particularly
with Ubuntu 18.04.

Following the required steps to make it work with Ubuntu 18.04.
Note that this not the only way to make it work.

```bash
# Enables buildx command by adding
#   "experimental": "enabled"
# in Docker's local configuration file...
vi $HOME/.docker/config.json

# {
#   ...
#   "experimental" : "enabled"
# }
```

Install the *qemu-user-static* and *binfmt-support* packages.
The first one adds `/usr/bin/qemu-<arch>-static` binaries that allows running
binaries of a specific `<arch>` architecture.
The second one adds the `/usr/sbin/update-binfmts` script that allows to easily
add interpreters related to custom file magic numbers (headers) or extensions.

```bash
sudo apt install --yes \
    qemu-user-static \
    binfmt-support
```

Normally, the *qemu-user-binfmt package* only runs a script that adds qemu
entries to the `/proc/sys/fs/binfmt_misc` directory with the "F" flag, required
for an automated run of different architectures binaries.
The script is bugged in Ubuntu 18.04 and even if it adds entries, they don't
hold the "F" flag.

Following is a method that adds the entries correctly using another
script (source [here](https://gist.github.com/ArturKlauser/94214134728e90a163dd58c27010ed9c)).
This step has to be done once.

```bash
sudo ./reregister-qemu-binfmt.sh
```

Or directly using the online script:


```bash
sudo curl -fsSL https://gist.githubusercontent.com/ArturKlauser/94214134728e90a163dd58c27010ed9c/raw/eddd834659bc6893a37d865d3cc2df8ca2192d7c/reregister-qemu-binfmt.sh | sudo sh
```

Now you are ready with the `docker buildx` command.
To allow multi-architectures builds in parallel, you have to create a dedicated
builder which will run within a Docker container.
Let's create and select one.
We arbitrarily attribute the `multiarch-builder` name to it.

```bash
docker buildx create --name multiarch-builder
docker buildx use multiarch-builder
```

You can check that this builder is now the selected one (a `*` appears next to
the builder's name).

```bash
docker buildx ls
NAME/NODE            DRIVER/ENDPOINT             STATUS   PLATFORMS
multiarch-builder *  docker-container                     
  multiarch-builder0 unix:///var/run/docker.sock inactive  
default              docker                               
  default            default                     running  linux/amd64, linux/arm64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6```
```

Moreover, you can check its managed architectures.
To do so, the builder must be started first.

```bash
docker buildx inspect --bootstrap
Name:   multiarch-builder
Driver: docker-container

Nodes:
Name:      multiarch-builder0
Endpoint:  unix:///var/run/docker.sock
Status:    running
Platforms: linux/amd64, linux/arm64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
```

Finally, you can quickly check your builders and which one is selected with the
following command.

```bash
docker buildx ls
NAME/NODE            DRIVER/ENDPOINT             STATUS  PLATFORMS
multiarch-builder *  docker-container                    
  multiarch-builder0 unix:///var/run/docker.sock running linux/amd64, linux/arm64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
default              docker                              
  default            default                     running linux/amd64, linux/arm64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
```

Now let's connect to the registry you want to push multi-architecture images to
(example with DockerHub and the *jbaptperez* account).

```bash
docker login --username jbaptperez --password-stdin
# Type your password
```

To build a multi-architecture image, you just have to assert that the base image
of your Dockerfile is also a multi-architecture one, holding architectures you
are targeting.
This is the case of Ubuntu and Debian images, used in this repository.

You are now ready to build and push a multi-architecture image in a single
command.
Example with the *d-bus-service* image, assuming your current directory is the
root of this repository:

```bash
docker buildx \
    build \
    --platform=linux/amd64,linux/arm64,linux/386,linux/arm/v7 \
    --tag=jbaptperez/d-bus-service:latest \
    --push \
    d-bus-service/
```
This commands asks for a parallel build of 4 images for 4 architectures (the
exact architecture names are retrieved thanks to the `docker buildx ls`
command).
The tag to apply to images is the same (multi-architectures):
`jbaptperez/wirepas-sink-service:latest`.
Once images are build, just send them as a multi-architecture tag to the current
registry (Docker Hub).
The `d-bus-service.` indicates the Dockerfile location for building.

Note that once images are build, they remain cached in the builder's container
and are not transfered to host images.
You can transfer a single one to the host using the `--load` option instead of
`--push`.
This implies giving a single architecture to the `--platform` option.

Following is an example of *d-bus-service* build for ARM v7 architecture.
Once the image is created, it is transfered to the host (`--load`).
Then, we start a container for this image and display kernel information.
This container transparently uses the *quemu-arm-static* binary to properly
run on the host.

```bash
docker buildx \
    build \
    --platform=linux/arm/v7 \
    --tag=jbaptperez/d-bus-service:latest \
    --load \
    d-bus-service/
docker run --rm jbaptperez/d-bus-service uname -a

```

Assuming your current directory is the root of this repository, you can build
and push every images thanks to a single *for* loop.

```bash
for service in $(echo *-service); do
    echo "Building and pushing ${service}..."
    docker buildx \
        build \
        --platform=linux/amd64,linux/arm64,linux/386,linux/arm/v7 \
        --tag=jbaptperez/wirepas-${service}:latest \
        --push \
        ${service}/
done
```




