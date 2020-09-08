# artis3n/pgmodeler

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/artis3n/pgmodeler-container?style=flat-square)](https://github.com/users/artis3n/packages/container/pgmodeler)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/artis3n/pgmodeler-container/Test?style=flat-square)](https://github.com/artis3n/pgmodeler-container/actions)
![GitHub last commit](https://img.shields.io/github/last-commit/artis3n/pgmodeler-container?style=flat-square)
![GitHub](https://img.shields.io/github/license/artis3n/pgmodeler-container?style=flat-square)
![GitHub followers](https://img.shields.io/github/followers/artis3n?style=social)
![Twitter Follow](https://img.shields.io/twitter/follow/artis3n?style=social)

Docker image wrapping [pgmodeler/pgmodeler][pgmodeler repo]. Unlike other containers I've seen for this project, this container is **_secure by default_**. There is no `--privileged` or any capabilities passed to the container. There is a non-root user. You get the graphical interface for PGModeler and can save project files to a specified volume for persistence.

Download from GitHub Container Registry or Docker Hub:

```bash
docker pull ghcr.io/artis3n/pgmodeler:latest
docker pull artis3n/pgmodeler:latest
```

## Usage

Run the container:

```bash
xhost +local:
docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix ghcr.io/artis3n/pgmodeler:latest
xhost -local:
```

| :exclamation: To persist your project data, be sure to mount a directory to `/app/savedwork` |
| --- |

```bash
xhost +local:
docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /persistent/local/directory/for/project:/app/savedwork ghcr.io/artis3n/pgmodeler:latest
xhost -local:
```

Then, while working in PGModeler, be sure to save your project files to `/app/savedwork`. Done!

[pgmodeler repo]: https://github.com/pgmodeler/pgmodeler
