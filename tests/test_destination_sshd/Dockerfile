#
# Based on:  https://github.com/rastasheep/ubuntu-sshd
#

FROM ubuntu:14.04

RUN apt-get clean && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        rsync \
    && \
    apt-get clean && \
    mkdir /var/run/sshd

RUN echo 'root:test_destination_sshd' | chpasswd && \
    sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config

EXPOSE 22

CMD    ["/usr/sbin/sshd", "-D"]
