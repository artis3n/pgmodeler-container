# Cannot use alpine because it uses musl instead of glibc and musl doesn't have "backtrace"
# https://github.com/openalpr/openalpr/issues/566#issuecomment-348205549
FROM ubuntu:22.04 as compiler
LABEL maintainer="Artis3n <dev@artis3nal.com>"

ARG INSTALLATION_ROOT=/app
ARG QMAKE_PATH=/usr/bin/qmake
ARG QT_ROOT=/usr/lib/qt6
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    # qt6-default = qt6-base-dev qtchooser qmake6 qt6-base-dev-tools
    && apt-get -y install --no-install-recommends \
        build-essential \
        ca-certificates \
        git \
        libgl1-mesa-dev libqt6opengl6-dev \
        libglx-dev \
        libboost-dev \
        libpq-dev \
        libqt6svg6-dev \
        libxml2 \
        libxml2-dev \
        libxext-dev \
        pkg-config \
        qt6-base-dev qtchooser qmake6 qt6-base-dev-tools \
        qt6-tools-dev \
    # Slim down layer size
    # Not strictly necessary since this is a multi-stage build but hadolint would complain
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    # Remove apt-get cache from the layer to reduce container size
    && rm -rf /var/lib/apt/lists/*

# Configure QT6
RUN qtchooser -install qt6 $(which qmake6) \
    && cp /usr/lib/$(uname -p)-linux-gnu/qt-default/qtchooser/qt6.conf /usr/share/qtchooser/qt6.conf \
    && mkdir -p /usr/lib/$(uname -p)-linux-gnu/qt-default/qtchooser \
    && ln -n /usr/share/qtchooser/qt6.conf /usr/lib/$(uname -p)-linux-gnu/qt-default/qtchooser/default.conf

# Copy project files
COPY ./pgmodeler /pgmodeler
COPY ./plugins /pgmodeler/plugins

# Configure the SQL-join graphical query builder plugin
WORKDIR /pgmodeler/plugins/graphicalquerybuilder
RUN ./setup.sh paal \
   && sed -i.bak s/GQB_JOIN_SOLVER=\"n\"/GQB_JOIN_SOLVER=\"y\"/ graphicalquerybuilder.conf \
   && sed -i.bak s/BOOST_INSTALLED=\"n\"/BOOST_INSTALLED=\"y\"/ graphicalquerybuilder.conf

WORKDIR /pgmodeler
RUN mkdir /app \
    # Add persistence folder for project work
    && mkdir /app/savedwork \
    # Configure qmake for compilation
    && "$QMAKE_PATH" -version \
    && pkg-config libpq --cflags --libs \
    && "$QMAKE_PATH" -r \
        CONFIG+=release \
        PREFIX="$INSTALLATION_ROOT" \
        BINDIR="$INSTALLATION_ROOT" \
        PRIVATEBINDIR="$INSTALLATION_ROOT" \
        PRIVATELIBDIR="$INSTALLATION_ROOT/lib" \
        pgmodeler.pro \
    # Compile PgModeler - will take about 20 minutes
    && make -j"$(nproc)" \
    && make install

# Resolve dependencies
RUN mkdir "$INSTALLATION_ROOT"/lib/qtplugins \
    && mkdir "$INSTALLATION_ROOT"/lib/qtplugins/imageformats \
    && mkdir "$INSTALLATION_ROOT"/lib/qtplugins/printsupport \
    && mkdir "$INSTALLATION_ROOT"/lib/qtplugins/platforms \
    && echo -e "[Paths]\nPrefix=.\nPlugins=lib/qtplugins\nLibraries=lib" > "$INSTALLATION_ROOT"/qt.conf \
    && cd "QT_ROOT"/lib \
    && cp libQt6DBus.so.6 libQt6PrintSupport.so.6 libQt6Widgets.so.6 libQt6Network.so.6 libQt6Gui.so.6 libQt6Core.so.6 libQt5XcbQpa.so.6 libQt6Svg.so.6 libicui18n.so.* libicuuc.so.* libicudata.so.* "$INSTALLATION_ROOT"/lib \
    && cd "QT_ROOT"/plugins \
    && cp -r imageformats/libqgif.so imageformats/libqico.so imageformats/libqjpeg.so imageformats/libqsvg.so "$INSTALLATION_ROOT"/lib/qtplugins/imageformats \
    && cp -r printsupport/libcupsprintersupport.so "$INSTALLATION_ROOT"/lib/qtplugins/printsupport \
    && cp -r platforms/libqxcb.so platforms/libqoffscreen.so "$INSTALLATION_ROOT"/lib/qtplugins/platforms \
    && mkdir "$INSTALLATION_ROOT"/lib/qtplugins/tls \
    && cp -r platforms/tls/* "$INSTALLATION_ROOT"/lib/qtplugins/tls


# Now that the image is compiled, we can remove most of the image size bloat
FROM ubuntu:22.04 as app
LABEL maintainer="Artis3n <dev@artis3nal.com>"

ARG DEBIAN_FRONTEND=noninteractive
ARG INSTALLATION_ROOT=/app

RUN apt-get update \
    # qt6-default = qt6-base-dev qtchooser qmake6 qt6-base-dev-tools
    && apt-get -y install --no-install-recommends \
        libpq-dev \
        libqt6svg6-dev \
        libxml2 \
        qt6-base-dev qtchooser qmake6 qt6-base-dev-tools \
    # Slim down layer size
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    # Remove apt-get cache from the layer to reduce container size
    && rm -rf /var/lib/apt/lists/*

# Configure QT6
RUN qtchooser -install qt6 $(which qmake6) \
    && cp /usr/lib/$(uname -p)-linux-gnu/qt-default/qtchooser/qt6.conf /usr/share/qtchooser/qt6.conf \
    && mkdir -p /usr/lib/$(uname -p)-linux-gnu/qt-default/qtchooser \
    && ln -n /usr/share/qtchooser/qt6.conf /usr/lib/$(uname -p)-linux-gnu/qt-default/qtchooser/default.conf

# Set up non-root user
RUN groupadd -g 1000 modeler \
    && useradd -m -u 1000 -g modeler modeler

COPY --chown=modeler:modeler --from=compiler /${INSTALLATION_ROOT} /app

USER modeler
WORKDIR /app

ENV QT_X11_NO_MITSHM=1
ENV QT_GRAPHICSSYSTEM=native

ENTRYPOINT ["/app/pgmodeler"]
