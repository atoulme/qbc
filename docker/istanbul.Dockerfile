FROM ubuntu:16.04
ARG osarch
ARG version
COPY istanbul-tools-${version}-${osarch}.tar.gz /tmp/

RUN cd /opt \
    && tar xzf /tmp/istanbul-tools-${version}-${osarch}.tar.gz \
    && rm /tmp/istanbul-tools-${version}-${osarch}.tar.gz \
    && chmod +x /opt/istanbul

CMD ["/opt/istanbul"]

