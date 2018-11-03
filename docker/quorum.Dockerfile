FROM ubuntu:16.04
ARG osarch
ARG version
COPY quorum-${version}-${osarch}.tar.gz /tmp/

RUN apt-get update -qq \
  && apt-get install -y -q jq zip

RUN cd /opt \
  && tar xzf /tmp/quorum-${version}-${osarch}.tar.gz \
  && rm /tmp/quorum-${version}-${osarch}.tar.gz \
  && chmod +x /opt/geth

COPY quorum-start.sh /opt/quorum-start.sh

RUN chmod +x /opt/quorum-start.sh

CMD ["/opt/quorum-start.sh"]