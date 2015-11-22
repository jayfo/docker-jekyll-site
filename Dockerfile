FROM ubuntu:14.04

# Install the packages we need for getting things done
RUN apt-get update && \
    apt-get install -y \
      build-essential \
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

# Install the packages we need for Jekyll
RUN apt-get update && \
    apt-get install -y \
      node \
      python3 \
      python3-pip \
      python3.4-venv \
      ruby \
      ruby-dev \
    && \
    apt-get clean

# Install Ruby
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-add-repository ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install -y ruby2.2 && \
    apt-get install -y ruby-switch && \
    ruby-switch --list && \
    ruby-switch --set ruby2.2.3 && \
    ruby -v

RUN apt-get update && \
    apt-get install -y \
      node \
      python3 \
      python3-pip \
      python3.4-venv \
      ruby \
      ruby-dev \
    && \
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

http://stackoverflow.com/a/9056395/497756
