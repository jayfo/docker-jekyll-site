FROM ubuntu:14.04

# Unicode command line
ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8"

# Install the packages we need for getting things done
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      curl \
      dos2unix \
      git \
    && \
    apt-get clean

# Install the packages we need for publishing
RUN apt-get update && \
    apt-get install -y \
      gawk \
      sshpass \
    && \
    apt-get clean

# Install Python
# RUN apt-get update && \
#    apt-get install -y \
#      python3 \
#      python3-pip \
#      python3.4-venv \
#    && \
#    apt-get clean

RUN apt-get update && \
    apt-get install -y \
      software-properties-common \
    && \
    apt-add-repository ppa:fkrull/deadsnakes && \
    apt-get update && \
    apt-get install -y \
      python3.5 \
      python-virtualenv \
    &&\
    apt-get clean

# Install Ruby
RUN command curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    \curl -L https://get.rvm.io | bash -s stable && \
    /usr/local/rvm install 2.2.3 && \
    /usr/local/rvm use 2.2.3
    
# RUN apt-get update && \
#     apt-get install -y \
#       software-properties-common \
#     && \
#     apt-add-repository ppa:brightbox/ruby-ng && \
#     apt-get update && \
#     apt-get install -y \
#       ruby2.2 \
#       ruby2.2-dev \
#       ruby-switch \
#     && \
#     ruby-switch --list && \
#     ruby-switch --set ruby2.2 && \
#     apt-get clean

# Install Node.js
RUN apt-get update && \
    apt-get install -y \
      curl \
    && \
    curl -sL https://deb.nodesource.com/setup | sudo bash - && \
    apt-get update && \
    apt-get install -y \
      nodejs \
    && \
    npm install npm -g && \
    apt-get clean

# Port where we serve the files
EXPOSE 4000

# Volume where the site will persist
VOLUME ["/site"]

# Our wrapper script
COPY run.sh /tmp/run.sh
RUN dos2unix /tmp/run.sh
RUN chmod a+x /tmp/run.sh

# Run the wrapper script
CMD ["/tmp/run.sh"]
