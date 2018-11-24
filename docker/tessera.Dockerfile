FROM ubuntu:16.04

RUN apt-get update -qq && apt-get install -y openjdk-8-jre -qq

COPY tessera*.tar.gz /tmp/tessera.tar.gz

RUN cd /opt && \
  tar xzf /tmp/tessera.tar.gz && \
  rm /tmp/tessera.tar.gz && \
  mv *.jar tessera-app.jar
  
COPY tessera-start.sh /opt/tessera-start.sh

RUN chmod +x /opt/tessera-start.sh
  
ENV JAVA_OPTS="-Xmx1024m"
  
CMD ["/opt/tessera-start.sh"]
