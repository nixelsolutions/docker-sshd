FROM ubuntu:22.04

MAINTAINER Manel Martinez <manel@nixelsolutions.com>

RUN apt-get update && \
    apt-get install -y openssh-server

EXPOSE 22

RUN mkdir -p /var/run/sshd

ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/*.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
