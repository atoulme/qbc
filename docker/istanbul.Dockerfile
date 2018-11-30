FROM ubuntu:16.04
ARG osarch
ARG version
COPY istanbul-${version}-${osarch}.tar.gz /tmp/

RUN cd /opt \
    && tar xzf /tmp/istanbul-${version}-${osarch}.tar.gz \
    && rm /tmp/istanbul-${version}-${osarch}.tar.gz \
    && chmod +x /opt/istanbul

COPY istanbul-start.sh /opt/istanbul-start.sh

RUN chmod +x /opt/istanbul-start.sh

CMD ["/opt/istanbul"]

