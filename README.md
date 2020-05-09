# artis3n/pgmodeler <!-- omit in toc -->

Docker image wrapping [pgmodeler/pgmodeler][pgmodeler repo].

This image supports connecting to a Postgres container running on a [Docker network][] as well as persistent project files and schemas via a Docker volume.

| :exclamation: This image is under active development and is not yet feature-complete. |
| --- |

To do:

- [ ] Support Postgres running on Docker user-defined network
- [ ] Persist project files via a `-v` volume

## Usage

Run the container:

```bash
xhost +local:
docker run -it --rm -e DISPLAY=$$DISPLAY -e QT_GRAPHICSSYSTEM=native -v /tmp/.X11-unix:/tmp/.X11-unix artis3n/pgmodeler:latest
xhost -local:
```

[docker network]: https://docs.docker.com/network/bridge/#manage-a-user-defined-bridge
[pgmodeler repo]: https://github.com/pgmodeler/pgmodeler
