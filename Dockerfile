# Cannot use alpine because it uses musl instead of glibc and musl doesn't have "backtrace"
# https://github.com/openalpr/openalpr/issues/566#issuecomment-348205549
FROM ubuntu:20.10 as compiler

ARG INSTALLATION_ROOT=/app
ARG QMAKE_PATH=/usr/bin/qmake
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        build-essential \
        git \
        libboost-dev \
        libpq-dev \
        libqt5svg5-dev \
        libxml2 \
        libxml2-dev \
        pkg-config \
        qt5-default \
        qttools5-dev \
    # Slim down layer size
    # Not strictly necessary since this is a multi-stage build but hadolint would complain
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    # Remove apt-get cache from the layer to reduce container size
    && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY ./pgmodeler /pgmodeler
COPY ./plugins /pgmodeler/plugins

# fatal: unable to access 'http://siekiera.mimuw.edu.pl:8082/paal/': Failed to connect to siekiera.mimuw.edu.pl port 8082: Connection timed out
# https://github.com/pgmodeler/plugins/issues/16
#
# Configure the SQL-join graphical query builder plugin
# WORKDIR /pgmodeler/plugins/graphicalquerybuilder
# RUN ./setup.sh paal \
#     && sed -i.bak s/GQB_JOIN_SOLVER=\"n\"/GQB_JOIN_SOLVER=\"y\"/ graphicalquerybuilder.conf \
#     && sed -i.bak s/BOOST_INSTALLED=\"n\"/BOOST_INSTALLED=\"y\"/ graphicalquerybuilder.conf

WORKDIR /pgmodeler
RUN mkdir /app \
    # Add persistence folder for project work
    && mkdir /app/savedwork \
    # Configure qmake for compilation
    && "$QMAKE_PATH" -version \
    && pkg-config libpq --cflags --libs \
    && "$QMAKE_PATH" -r CONFIG+=release \
        PREFIX="$INSTALLATION_ROOT" \
        BINDIR="$INSTALLATION_ROOT" \
        PRIVATEBINDIR="$INSTALLATION_ROOT" \
        PRIVATELIBDIR="$INSTALLATION_ROOT/lib" \
        pgmodeler.pro \
    # Compile PgModeler - will take about 20 minutes
    && make -j"$(nproc)" \
    && make install

# Now that the image is compiled, we can remove most of the image size bloat
FROM ubuntu:20.10 as app
LABEL name="artis3n/pgmodeler"
LABEL version="1.3.1"
LABEL maintainer="Artis3n <dev@artis3nal.com>"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        libpq-dev \
        libqt5svg5-dev \
        libxml2 \
        qt5-default \
    # Slim down layer size
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    # Remove apt-get cache from the layer to reduce container size
    && rm -rf /var/lib/apt/lists/*

# Set up non-root user
RUN groupadd -g 1000 modeler \
    && useradd -m -u 1000 -g modeler modeler

COPY --chown=modeler:modeler --from=compiler /app /app

USER modeler
WORKDIR /app

ENV QT_X11_NO_MITSHM=1
ENV QT_GRAPHICSSYSTEM=native

ENTRYPOINT ["/app/pgmodeler"]
