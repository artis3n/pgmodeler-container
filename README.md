# artis3n/pgmodeler

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/artis3n/pgmodeler-container?style=flat-square)](https://github.com/users/artis3n/packages/container/pgmodeler)
![CircleCI](https://img.shields.io/circleci/build/github/artis3n/pgmodeler-container/main?style=flat-square)
[![Docker Pulls](https://img.shields.io/docker/pulls/artis3n/pgmodeler?style=flat-square)](https://hub.docker.com/repository/docker/artis3n/pgmodeler)
![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/artis3n/pgmodeler?label=image%20size%20%28compressed%29&style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/artis3n/pgmodeler-container?style=flat-square)
![GitHub](https://img.shields.io/github/license/artis3n/pgmodeler-container?style=flat-square)
![GitHub followers](https://img.shields.io/github/followers/artis3n?style=social)
![Twitter Follow](https://img.shields.io/twitter/follow/artis3n?style=social)

Docker image wrapping [pgmodeler/pgmodeler][pgmodeler repo]. Unlike other containers I've seen for this project, this container is **_secure by default_**. There is no `--privileged` or any capabilities passed to the container. There is a non-root user. You don't over-expose your Xserver. You get the graphical interface for PGModeler and can save project files to a specified volume for persistence with peace of mind. Best of all, this container weighs just under 400 MB!

Download from GitHub Container Registry or Docker Hub:

```bash
docker pull ghcr.io/artis3n/pgmodeler:latest
docker pull artis3n/pgmodeler:latest
```

I [wrote an article][blog article] explaining in detail how I set up this container to be secure.
Check it out!

## Usage

First, discover the location of your `.Xauthority` file.
See the above article for details on what we are doing here if you are not familiar and are interested.
Then run the container (dropping all of Docker's default Linux capabilities, as they are not needed).

```bash
XAUTHORITY=$(xauth info | grep "Authority file" | awk '{ print $3 }')

docker run --rm --cap-drop=all \
    -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v $XAUTHORITY:/home/modeler/.Xauthority:ro \
    ghcr.io/artis3n/pgmodeler:latest
```

| :exclamation: To persist your project data, be sure to mount a directory to `/app/savedwork` |
| --- |

```bash
XAUTHORITY=$(xauth info | grep "Authority file" | awk '{ print $3 }')

docker run --rm --cap-drop=all \
    -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v $XAUTHORITY:/home/modeler/.Xauthority:ro \
    -v /persistent/local/directory/for/project:/app/savedwork \
    ghcr.io/artis3n/pgmodeler:latest
```

Then, while working in PGModeler, be sure to save your project files to `/app/savedwork`. Done!

### OSX Hosts

For OSX hosts, you have to install a Linux-compatible X11 server. The most common option is [XQuartz][].

The steps are:

1. `brew cask install xquartz`
1. `open -a XQuartz`
    1. Ensure XQuartz is running whenever you want to run this image.
1. XQuartz preferences -> Security -> check "Allow connections from network clients"
1. Make sure `/usr/X11/bin` is in your PATH
1. Set your `DISPLAY` appropriately

```bash
# Check to make sure your WiFi device is en0. If not, replace en0 with the appropriate device.
export DISPLAY=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}'):0
```

Now you can run the container with the regular instructions:

```bash
XAUTHORITY=$(xauth info | grep "Authority file" | awk '{ print $3 }')

docker run --rm --cap-drop=all \
    -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v $XAUTHORITY:/home/modeler/.Xauthority:ro \
    -v /persistent/local/directory/for/project:/app/savedwork \
    ghcr.io/artis3n/pgmodeler:latest
```

[blog article]: https://blog.artis3nal.com/2020-09-13-container-gui-app-pgmodeler/
[pgmodeler repo]: https://github.com/pgmodeler/pgmodeler
[xquartz]: https://www.xquartz.org/
