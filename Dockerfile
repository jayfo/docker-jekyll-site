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
      python-pygments \
      ruby \
      ruby-dev \
    && \
    apt-get clean

# Install jekyll
RUN gem install \
      jekyll

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
