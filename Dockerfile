# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CALIBRE_RELEASE
ARG CALIBRE_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

ENV \
  CUSTOM_PORT="8080" \
  CUSTOM_HTTPS_PORT="8181" \
  HOME="/config" \
  TITLE="Calibre" \
  QTWEBENGINE_DISABLE_SANDBOX="1"

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/calibre-icon.png && \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    dbus \
    fcitx-rime \
    fonts-wqy-microhei \
    libnss3 \
    libopengl0 \
    libqpdf29t64 \
    libxkbcommon-x11-0 \
    libxcb-cursor0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    poppler-utils \
    python3 \
    python3-xdg \
    ttf-wqy-zenhei \
    wget \
    xz-utils \
    speech-dispatcher \
    xchm \
    xpdf

## to prevent downloading everytime your run docker build, run following in current directory
# wget http://archive.ubuntu.com/ubuntu/pool/universe/x/xpdf/xpdf_3.04-7_amd64.deb
# wget http://security.ubuntu.com/ubuntu/pool/main/p/poppler/libpoppler73_0.62.0-2ubuntu2.14_amd64.deb
## and uncomment following lines
# COPY libpoppler73_0.62.0-2ubuntu2.14_amd64.deb /tmp/libpoppler73_0.62.0-2ubuntu2.14_amd64.deb
# COPY xpdf_3.04-7_amd64.deb /tmp/xpdf_3.04-7_amd64.deb
#
# RUN \
#   echo "**** install xpdf ****" && \
#   LIBPOPPLER_DEB_URL="http://security.ubuntu.com/ubuntu/pool/main/p/poppler/libpoppler73_0.62.0-2ubuntu2.14_amd64.deb" && \
#   XPDF_DEB_URL="http://archive.ubuntu.com/ubuntu/pool/universe/x/xpdf/xpdf_3.04-7_amd64.deb" && \
#   LIBPOPPLER_DEB="/tmp/libpoppler73_0.62.0-2ubuntu2.14_amd64.deb" && \
#   XPDF_DEB="/tmp/xpdf_3.04-7_amd64.deb" && \
#   if [ ! -f "${LIBPOPPLER_DEB}" ]; then curl -o "${LIBPOPPLER_DEB}" -L "${LIBPOPPLER_DEB_URL}"; fi && \
#   if [ ! -f "${XPDF_DEB}" ]; then curl -o "${XPDF_DEB}" -L "${XPDF_DEB_URL}"; fi && \
#   apt-get install --yes --no-install-recommends \
#      "${LIBPOPPLER_DEB}" "${XPDF_DEB}" && \
#   apt-get update && \
#   apt-get upgrade --yes --fix-broken --fix-missing && \
#   /bin/rm -f "${LIBPOPPLER_DEB}" "${XPDF_DEB}"

## to prevent downloading everytime your run docker build, run following in current directory
# CALIBRE_RELEASE=$(curl -sX GET "https://api.github.com/repos/kovidgoyal/calibre/releases/latest" | jq -r .tag_name) \
#   && CALIBRE_VERSION=$(curl -sX GET "https://api.github.com/repos/kovidgoyal/calibre/releases/latest" | jq -r .tag_name | cut -c2-) \
#   && wget https://github.com/kovidgoyal/calibre/releases/download/${CALIBRE_VERSION}/calibre-${CALIBRE_VERSION}-x86_64.txz
## and uncomment following line
COPY calibre-${CALIBRE_VERSION}-x86_64.txz /tmp/calibre-tarball.txz

RUN \
  echo "**** install calibre ****" && \
  mkdir -p /opt/calibre && \
  if [ -z ${CALIBRE_RELEASE+x} ]; then \
    CALIBRE_RELEASE=$(curl -sX GET "https://api.github.com/repos/kovidgoyal/calibre/releases/latest" | jq -r .tag_name); \
  fi && \
  CALIBRE_VERSION="$(echo ${CALIBRE_RELEASE} | cut -c2-)" && \
  CALIBRE_URL="https://download.calibre-ebook.com/${CALIBRE_VERSION}/calibre-${CALIBRE_VERSION}-x86_64.txz" && \
  CALIBRE_URL="https://github.com/kovidgoyal/calibre/releases/download/${CALIBRE_RELEASE}/calibre-${CALIBRE_VERSION}-x86_64.txz" && \
  CALIBRE_TAR="/tmp/calibre-tarball.txz" && \
  if [ ! -f "${CALIBRE_TAR}" ]; then curl -o "${CALIBRE_TARBALL}" -L "${CALIBRE_URL}"; fi && \
  tar xvf "${CALIBRE_TAR}" -C /opt/calibre && \
  /opt/calibre/calibre_postinstall && \
  dbus-uuidgen > /etc/machine-id && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  /bin/rm -rf \
    ${CALIBRE_TAR} \
    /tmp/* \
    /tmp/.[xX]* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /
