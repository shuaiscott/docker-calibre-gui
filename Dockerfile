# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.12-glibc

RUN add-pkg xdg-utils
RUN add-pkg wget
RUN add-pkg xz
RUN add-pkg python3
RUN add-pkg sudo
RUN add-pkg libstdc++6
RUN add-pkg libgcc
RUN add-pkg xcb-util
RUN add-pkg nss
RUN add-pkg qt5-qtbase-x11
RUN add-pkg libbsd

RUN \
sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

# Copy the start script.
COPY startapp.sh /startapp.sh

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/kovidgoyal/calibre/raw/master/icons/calibre.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Set the name of the application.
ENV APP_NAME="Calibre"
