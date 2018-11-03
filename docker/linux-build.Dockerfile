FROM ubuntu:16.04

ENV LANG en_US.UTF-8
ENV GOVERSION 1.9.1
ENV GOROOT /opt/go
ENV GOPATH /root/.go

RUN apt-get update -qq \
    && apt-get -y -qq install libdb-dev libpthread-stubs0-dev build-essential libleveldb-dev libsodium-dev zlib1g-dev libtinfo-dev wget curl git openjdk-8-jdk gnupg git autoconf libtool\
    && wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
    && dpkg -i erlang-solutions_1.0_all.deb \
    && rm erlang-solutions_1.0_all.deb \
    && apt-get update -qq \
    && apt-get install -y esl-erlang elixir \
    && cd /opt && wget -q https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz \
    && tar zxf go${GOVERSION}.linux-amd64.tar.gz \
    && rm go${GOVERSION}.linux-amd64.tar.gz \
    && ln -s /opt/go/bin/go /usr/bin/ \
    && mkdir ${GOPATH}

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash \
    && apt-get install -y nodejs

RUN curl -sSL https://get.haskellstack.org/ | sh && stack setup

RUN mkdir -p /opt \
    && cd /opt \
    && wget http://apache.osuosl.org/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz \
    && tar xzf apache-maven-3.6.0-bin.tar.gz \
    && rm apache-maven-3.6.0-bin.tar.gz
    
ENV M2_HOME /opt/apache-maven-3.6.0
ENV PATH="/opt/apache-maven-3.6.0/bin:${PATH}"
ARG CACHEBUST=1

RUN echo "#!/bin/bash\ncd /tmp/constellation && stack --allow-different-user install && cp /root/.local/bin/constellation-node /tmp/constellation/bin/ && ldd /tmp/constellation/bin/constellation-node | cut -f3- -d ' ' | grep '^/.*' | cut -f1 -d ' '| xargs -I '{}' cp -v '{}' /tmp/constellation/bin/" > build-constellation.sh && chmod +x build-constellation.sh \
    && echo "#!/bin/bash\ncd /tmp/crux && make setup && make build" > build-crux.sh && chmod +x build-crux.sh \
    && echo "#!/bin/bash\ncd /tmp/quorum && make all" > build-quorum.sh && chmod +x build-quorum.sh \
    && echo "#!/bin/bash\ncd /tmp/istanbul && mkdir -p /tmp/istanbul/.build/src/github.com/jpmorganchase/ && ln -sf /tmp/istanbul /tmp/istanbul/.build/src/github.com/jpmorganchase/istanbul-tools && export GOPATH=/tmp/istanbul/.build && cd /tmp/istanbul/.build/src/github.com/jpmorganchase/istanbul-tools && make" > build-istanbul.sh && chmod +x build-istanbul.sh \
    && echo "#!/bin/bash\nMIX_ENV=prod mix do deps.get, release --env prod" > build-blockscout.sh && chmod +x build-blockscout.sh
