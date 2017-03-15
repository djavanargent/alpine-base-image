FROM djavanargent/alpine-scratch:latest
MAINTAINER djavanargent

ENV MEDIAINFO_VERSION='0.7.93'

RUN \
  cd /build && \
  wget \
    "https://mediaarea.net/download/binary/mediainfo/${MEDIAINFO_VERSION}/MediaInfo_CLI_${MEDIAINFO_VERSION}_GNU_FromSource.tar.xz" \
    "https://mediaarea.net/download/binary/libmediainfo0/${MEDIAINFO_VERSION}/MediaInfo_DLL_${MEDIAINFO_VERSION}_GNU_FromSource.tar.xz" && \
  tar xpf "/build/MediaInfo_CLI_${MEDIAINFO_VERSION}_GNU_FromSource.tar.xz" && \
  tar xpf "/build/MediaInfo_DLL_${MEDIAINFO_VERSION}_GNU_FromSource.tar.xz" && \
  cd /build/MediaInfo_CLI_GNU_FromSource && \
  ./CLI_Compile.sh && \
  cd /build/MediaInfo_CLI_GNU_FromSource/MediaInfo/Project/GNU/CLI/ && \
  make install && \
  echo "CLI DONE" && \
  cd /build/MediaInfo_DLL_GNU_FromSource && \
  ./SO_Compile.sh && \
  cd /build/MediaInfo_DLL_GNU_FromSource/MediaInfoLib/Project/GNU/Library && \
  make install && \
  echo "MediaInfoLib DONE" && \
  cd /build/MediaInfo_DLL_GNU_FromSource/ZenLib/Project/GNU/Library && \
  make install && \
  echo "ZenLib DONE" && \
  rm -rf \
    /tmp/* \
    /build/* \
    /root/.cache \
    /root/.wget-hsts

ENTRYPOINT ["/init"]
