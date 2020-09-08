# artis3n/pgmodeler <!-- omit in toc -->

Docker image wrapping [pgmodeler/pgmodeler][pgmodeler repo].

This image supports connecting to a Postgres container running on a [Docker network][] as well as persistent project files and schemas via a Docker volume

## Usage

Run the container:

```bash
xhost +local:
docker run -it --rm -e DISPLAY=$$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix artis3n/pgmodeler:latest
xhost -local:
```

| :important: To persist your project data, be sure to mount a directory to `/app/savedwork` |
| --- |

```bash
xhost +local:
docker run -it --rm -e DISPLAY=$$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /persistent/local/directory/for/project:/app/savedwork artis3n/pgmodeler:$${TAG:-latest}
xhost -local:
```

[docker network]: https://docs.docker.com/network/bridge/#manage-a-user-defined-bridge
[pgmodeler repo]: https://github.com/pgmodeler/pgmodeler
