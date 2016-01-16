FROM ubuntu:14.04

# Unicode command line
ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8"

# Use bash instead of sh, fix stdin tty messages
RUN rm /bin/sh && ln -s /bin/bash /bin/sh && \
    sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile

# Install the packages we need for getting things done
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      curl \
      dos2unix \
      git \
      software-properties-common \
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
RUN apt-add-repository ppa:fkrull/deadsnakes && \
    apt-get update && \
    apt-get install -y \
      python3.5 \
      python-virtualenv \
    && \
    apt-get clean && \
    \
    virtualenv -p python3.5 /virtualenvs/env35 && \
    source /virtualenvs/env35/bin/activate && \
    pip install -U pip && \
    pip install invoke

# Install Ruby
RUN apt-add-repository ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install -y \
      ruby2.2-dev \
    && \
    apt-get clean && \
    \
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    curl -L https://get.rvm.io | /bin/bash -s stable && \
    echo 'source /etc/profile.d/rvm.sh' >> /etc/profile && \
    /bin/bash -l -c "rvm requirements" && \
    /bin/bash -l -c "rvm install 2.2.3" && \
    /bin/bash -l -c "rvm use --default 2.2.3" && \
    /bin/bash -l -c "gem install bundler" && \
    /bin/bash -l -c "rvm cleanup all"

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
