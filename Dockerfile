FROM debian
LABEL version="latest"
LABEL description="GRPC C++ Compilation & Golang installed"

ARG DEBIAN_FRONTEND=noninteractive

# Common Tools
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq git wget apt-utils nano vim

# Install Go language GRPC Cmake gives error if it is not installed
# Get Go language
# ---------------------------------------------------------------------
LABEL "version.go"="1.14.1"
RUN \
  cd /tmp && \
  wget -nv https://dl.google.com/go/go1.14.1.linux-amd64.tar.gz && \
  tar -xvf go1.14.1.linux-amd64.tar.gz && \
  mv go /usr/local
# Add Variables to ./profile
RUN echo 'export GOROOT=/usr/local/go' >> ~/.profile
RUN echo 'export GOPATH=$HOME/go'      >> ~/.profile
RUN echo 'export GOBIN=$GOPATH/bin'    >> ~/.profile
RUN echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH'  >> ~/.profile
# Current env Variables 
ENV GOROOT=/usr/local/go
ENV GOPATH=$HOME/go
ENV GOBIN=$GOPATH/bin
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH
# Get Packages
RUN go version
RUN go get -u google.golang.org/grpc
RUN go get -u github.com/golang/protobuf/protoc-gen-go
RUN go get -u github.com/stretchr/testify
# ---------------------------------------------------------------------

# C utilities

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
		gcc g++ curl wget gnupg sudo cmake \
		libyaml-dev libyaml-doc whois libjson-c-dev valgrind automake libtool \
		gettext binutils-dev binutils-doc gawk mawk pkg-config \
		build-essential manpages-dev man-db libx11-dev autoconf \
		libgflags-dev clang libc++-dev libunwind-dev


LABEL "version.grpc"="v1.27.3"
RUN \
	cd /tmp \
	&& git clone -b v1.27.3 --recursive https://github.com/grpc/grpc 

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq gcc


#Install GRP with CMAKE
RUN \
 	cd /tmp/grpc \
 	&& mkdir -p cmake/build \
 	&& cd cmake/build \
 	&& cmake ../.. \
 	&& make \
 	&& make install
		
RUN apt-get clean \
    && cd /temp \
	&& rm -R *

# Install Bazel 

# RUN \
# 	cd /tmp \
# 	&& curl https://bazel.build/bazel-release.pub.gpg | apt-key add - \
# 	&& echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
# 
# RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq bazel
# RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -yq full-upgrade
# RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq openjdk-11-jdk
# 
# Inatall GRP with Bazel
 
## RUN \
## 	cd /tmp/grpc \
## 	&& bazel build :all \
## 	&& bazel test --config=dbg //test/...