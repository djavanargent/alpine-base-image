FROM alpine:3.5
MAINTAINER djavanargent

ENV \
  PS1="$(whoami)@$(hostname):$(pwd)$ " \
  HOME='/root' \
  LANG='en_US.UTF-8' \
  LANGUAGE='en_US.UTF-8' \
  TERM='xterm'

RUN \
  echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
  apk -U upgrade --no-cache && \
  apk add --no-cache \
    bash \
    ca-certificates \
    coreutils \	
    curl \
    ffmpeg \
    file \
    freetype \
    git \
    geoip \
    gzip \
    lcms2 \
    libcurl \
    libjpeg-turbo \
    libwebp \
    openjpeg \
    openssl \
    p7zip \
    py2-lxml \
    python2 \
    shadow \
    sqlite \
    sqlite-libs \
    tar \
    tiff \
    unrar \
    unzip \
    wget \
    xz \
    zip \
    zlib && \
  apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/community \
    vnstat && \
  apk add --no-cache --virtual=build-dependencies \
    autoconf \
    automake \
    build-base \
    g++ \
    gcc \
    gd-dev \
    jpeg-dev \
    lcms2-dev \
    libffi-dev \
    libpng-dev \
    libwebp-dev \
    libtool \
    linux-headers \
    make \
    ncurses-dev \
    openjpeg-dev \
    openssl-dev \
    pkgconfig \
    python2-dev \
    tiff-dev \
    zlib-dev && \
  python -m ensurepip && \
  pip install --no-cache-dir -U \
    pip && \
  pip install --no-cache-dir -U \
    cheetah \
    configobj \
    configparser \
    feedparser \
    ndg-httpsclient \
    notify \
    paramiko \
    pillow \
    psutil \
    pyopenssl \
    requests \
    setuptools \
    urllib3 \
    virtualenv \
    http://www.golug.it/pub/yenc/yenc-0.4.0.tar.gz && \
  mkdir /build && \
  OVERLAY_VERSION=$(curl -sX GET "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]') && \
  curl -o /build/s6-overlay.tar.gz -L "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-amd64.tar.gz" && \
  tar zxvf /build/s6-overlay.tar.gz -C / && \
  groupmod -g 1000 users && \
  useradd -u 1001 -U -d /config -s /bin/false media && \
  usermod -G users media && \
  mkdir -p \
    /app \
    /build \
    /config \
    /defaults && \
  cd /build && \
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/unreleased/sgerrand.rsa.pub  -O /etc/apk/keys/sgerrand.rsa.pub && \
  wget \
    https://github.com/sgerrand/alpine-pkg-glibc/releases/download/unreleased/glibc-2.25-r1.apk \
    https://github.com/sgerrand/alpine-pkg-glibc/releases/download/unreleased/glibc-bin-2.25-r1.apk \
    https://github.com/sgerrand/alpine-pkg-glibc/releases/download/unreleased/glibc-dev-2.25-r1.apk \
    https://github.com/sgerrand/alpine-pkg-glibc/releases/download/unreleased/glibc-i18n-2.25-r1.apk && \
  apk add --no-cache \
    glibc-2.25-r1.apk \
    glibc-bin-2.25-r1.apk \
    glibc-dev-2.25-r1.apk \
    glibc-i18n-2.25-r1.apk && \
  /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
  echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
  git clone https://github.com/Parchive/par2cmdline /build/par2cmdline && \
  cd /build/par2cmdline && \
  aclocal && \
  automake --add-missing && \
  autoconf && \
  ./configure && \
  make && \
  make install && \
  cd /build && \
  MEDIAINFO_VERSION='0.7.93' && \
  wget \
    "https://mediaarea.net/download/binary/mediainfo/${MEDIAINFO_VERSION}/MediaInfo_CLI_${MEDIAINFO_VERSION}_GNU_FromSource.tar.xz" \
    "https://mediaarea.net/download/binary/libmediainfo0/${MEDIAINFO_VERSION}/MediaInfo_DLL_${MEDIAINFO_VERSION}_GNU_FromSource.tar.xz" && \
  tar xpf "/build/MediaInfo_CLI_${MEDIAINFO_VERSION}_GNU_FromSource.tar.xz" && \
  tar xpf "/build/MediaInfo_DLL_${MEDIAINFO_VERSION}_GNU_FromSource.tar.xz" && \
  cd /build/MediaInfo_CLI_GNU_FromSource && \
  ./CLI_Compile.sh && \
  cd /build/MediaInfo_CLI_GNU_FromSource/MediaInfo/Project/GNU/CLI/ && \
  make install && \
  cd /build/MediaInfo_DLL_GNU_FromSource && \
  ./SO_Compile.sh && \
  cd /build/MediaInfo_DLL_GNU_FromSource/MediaInfoLib/Project/GNU/Library && \
  make install && \
  cd /build/MediaInfo_DLL_GNU_FromSource/ZenLib/Project/GNU/Library && \
  make install && \
  apk del --purge \
    glibc-i18n \
  rm -rf \
    /tmp/* \
    /build/* \
    /usr/lib/python*/ensurepip \
    /var/cache/apk/* \
    /etc/apk/keys/sgerrand.rsa.pub \
    /root/.cache \
    /root/.wget-hsts

COPY root/ /

ENTRYPOINT ["/init"]
