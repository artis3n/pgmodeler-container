# Cannot use alpine because it uses musl instead of glibc and musl doesn't have "backtrace"
# https://github.com/openalpr/openalpr/issues/566#issuecomment-348205549
FROM ubuntu:20.04
LABEL Name="artis3n/pgmodeler"
LABEL Version="0.1.0"
LABEL maintainer="Artis3n <dev@artis3nal.com>"

ARG INSTALLATION_ROOT=/app
ARG QMAKE_PATH=/usr/bin/qmake
ARG DEBIAN_FRONTEND=noninteractive
ARG TERM=xterm

RUN apt-get update \
    && apt-get -y install --no-install-recommends build-essential libpq-dev libqt5svg5-dev libxml2 libxml2-dev pkg-config qt5-default qttools5-dev \
    # Slim down layer size
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    # Remove apt-get cache from the layer to reduce container size
    && rm -rf /var/lib/apt/lists/*
RUN "$QMAKE_PATH" -version && pkg-config libpq --cflags --libs

# Copy project files
RUN mkdir /app
COPY ./pgmodeler ./pgmodeler
COPY ./plugins ./pgmodeler/plugins

# Set up non-root user
RUN groupadd -r modeler && useradd --no-log-init -r -g modeler modeler
RUN chown -R modeler:modeler /app && chown -R modeler:modeler /pgmodeler
USER modeler

WORKDIR /pgmodeler
RUN "$QMAKE_PATH" -r CONFIG+=release \
    PREFIX="$INSTALLATION_ROOT" \
    BINDIR="$INSTALLATION_ROOT" \
    PRIVATEBINDIR="$INSTALLATION_ROOT" \
    PRIVATELIBDIR="$INSTALLATION_ROOT/lib" \
    pgmodeler.pro

RUN make && make install

ENV QT_X11_NO_MITSHM=1

ENTRYPOINT ["/app/pgmodeler"]
