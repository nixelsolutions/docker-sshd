FROM ubuntu:14.04

MAINTAINER Manel Martinez <manel@nixelsolutions.com>

RUN apt-get update && \
    apt-get install -y openssh

ENV USER **ChangeMe**
ENV PASSWORD **ChangeMe**

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
