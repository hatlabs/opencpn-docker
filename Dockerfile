FROM ghcr.io/linuxserver/baseimage-selkies:ubuntunoble

# Set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Hat Labs version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Hat Labs"

# Title
ENV TITLE=OpenCPN

RUN \
  echo "**** add opencpn repository ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    software-properties-common \
    gpg-agent && \
  add-apt-repository ppa:opencpn/opencpn && \
  echo "**** install opencpn and dependencies ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    opencpn \
    xcalib && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# Add local files
COPY /root /

# Ports and volumes
EXPOSE 3000 3001 8082

VOLUME /config
