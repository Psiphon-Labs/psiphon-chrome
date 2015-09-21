# Dockerfile to build an image with the local version of psiphon-native-messaging-host
#
# See README.md for usage instructions.

FROM ubuntu:15.04

ENV GOVERSION=go1.5

# Install system-level dependencies.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install build-essential curl git mercurial upx gcc-mingw-w64-i686 gcc-mingw-w64-x86-64 gcc-multilib scons gcc g++ unzip tar wget zlib1g zlib1g-dev ruby ruby-dev rpm rpm-common rpm2cpio

# Install NSIS (build windows installers)
RUN mkdir -p /opt/nsis && cd /opt/nsis && \
  wget -qO - "http://downloads.sourceforge.net/project/nsis/NSIS%203%20Pre-release/3.0b2/nsis-3.0b2-src.tar.bz2?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fnsis%2Ffiles%2FNSIS%25203%2520Pre-release%2F3.0b2%2F&ts=1442435084&use_mirror=iweb" | tar xj && \
  wget -O nsis-3.0b2.zip "http://downloads.sourceforge.net/project/nsis/NSIS%203%20Pre-release/3.0b2/nsis-3.0b2.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fnsis%2Ffiles%2FNSIS%25203%2520Pre-release%2F3.0b2%2F&ts=1441568847&use_mirror=iweb" && unzip nsis-3.0b2.zip && rm nsis-3.0b2.zip && \
  cd nsis-3.0b2-src && scons SKIPSTUBS=all SKIPPLUGINS=all SKIPUTILS=all SKIPMISC=all NSIS_CONFIG_CONST_DATA=no PREFIX=/opt/nsis/nsis-3.0b2 install-compiler && \
  cd /opt/nsis/nsis-3.0b2 chmod +x bin/makensis && mkdir share && cd share && ln -s /opt/nsis/nsis-3.0b2 nsis

ENV PATH=$PATH:/opt/nsis/nsis-3.0b2/bin

# Install FPM (build .deb, .rpm (.pkg files can only be built from a Mac))
RUN gem install fpm

# Install Go.
ENV GOROOT=/usr/local/go GOPATH=/go
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

RUN curl -L https://storage.googleapis.com/golang/$GOVERSION.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
  tar -C /usr/local -xzf /tmp/go.tar.gz && \
  rm /tmp/go.tar.gz && \
  echo $GOVERSION > $GOROOT/VERSION

ENV CGO_ENABLED=1

RUN go get github.com/mitchellh/gox && go get github.com/pwaller/goupx

WORKDIR $GOPATH/src
