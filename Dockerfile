FROM ponylang/ponyc

# https://github.com/phusion/baseimage-docker/issues/319#issuecomment-590534455
ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]
RUN \
  apt-get update -y && \
  apt-get install -y apt-utils 2> >( grep -v 'debconf: delaying package configuration, since apt-utils is not installed' >&2 ) && \
  apt-get install -y --no-install-recommends libpcre2-dev make
