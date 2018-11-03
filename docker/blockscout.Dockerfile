FROM ubuntu:16.04
ARG osarch
ARG version

COPY blockscout-${version}-${osarch}.tar.gz /tmp/

RUN cd /opt \
    && tar xzf /tmp/blockscout-${version}-${osarch}.tar.gz \
    && rm /tmp/blockscout-${version}-${osarch}.tar.gz

COPY blockscout-start.sh /opt/blockscout-start.sh

RUN chmod +x /opt/blockscout-start.sh

RUN echo "#!/bin/bash\nmix do ecto.create, ecto.migrate\n" > /opt/blockscout-init.sh

RUN chmod +x /opt/blockscout-init.sh

ENV ETHEREUM_JSONRPC_VARIANT=geth
ENV COIN=ETH

CMD ["/opt/blockscout-start.sh"]
