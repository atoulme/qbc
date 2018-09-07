FROM ubuntu:16.04

RUN apt-get update -qq && apt-get install -y openjdk-8-jre -qq

COPY build/tessera*.tar.gz /tmp/tessera.tar.gz

RUN cd /opt && \
  tar xzf /tmp/tessera.tar.gz && \
  rm /tmp/tessera.tar.gz
  
ENV JAVA_OPTS="-Xmx1024m"
  
ENTRYPOINT ["java", "-jar", "tessera-app-*.jar", $JAVA_OPTS]


