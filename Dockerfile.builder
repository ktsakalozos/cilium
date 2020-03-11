#
# Cilium build-time dependencies.
# Image created from this file is used to build Cilium.
#
FROM docker.io/library/ubuntu:18.04

LABEL maintainer="maintainer@cilium.io"

WORKDIR /go/src/github.com/cilium/cilium

#
# Env setup for Go (installed below)
#
ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV PATH "$GOROOT/bin:$GOPATH/bin:$PATH"
ENV GO_VERSION 1.14

#
# Build dependencies
#
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --no-install-recommends \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		apt-utils \
		binutils \
		ca-certificates \
		cmake \
		coreutils \
		curl \
		gcc \
		git \
		iproute2 \
		libc6-dev \
		libc6-dev-i386 \
		libelf-dev \
		m4 \
		make \
		ninja-build \
		pkg-config \
		python \
		rsync \
		unzip \
		wget \
		zip \
		zlib1g-dev \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
# Install clang/llvm
#
RUN git clone --depth 1 -b master https://github.com/llvm/llvm-project.git llvm && \
	mkdir -p llvm/llvm/build/install && \
	cd llvm/ && \
	git checkout -b d941df363d1cb621a3836b909c37d79f2a3e27e2 d941df363d1cb621a3836b909c37d79f2a3e27e2 && \
	cd llvm/build && \
	cmake .. -G "Ninja" -DLLVM_TARGETS_TO_BUILD="BPF" -DLLVM_ENABLE_PROJECTS="clang" -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_RUNTIME=OFF && \
	ninja && \
	cp bin/clang /usr/bin/clang-git && \
	cp bin/llc /usr/bin/llc-git && \
	update-alternatives --install /usr/bin/clang clang /usr/bin/clang-git 100 && \
	update-alternatives --install /usr/bin/llc llc /usr/bin/llc-git 100

#
# Install Go
#
RUN curl -sfL https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz | tar -xzC /usr/local && \
        go get -d -u github.com/gordonklaus/ineffassign && \
        cd /go/src/github.com/gordonklaus/ineffassign && \
        git checkout -b 1003c8bd00dc2869cb5ca5282e6ce33834fed514 1003c8bd00dc2869cb5ca5282e6ce33834fed514 && \
        go install
