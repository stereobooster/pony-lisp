FROM ponylang/ponyc

ARG DEBIAN_FRONTEND=noninteractive

# zsh

RUN \
  apt-get update -y && \
  apt-get install -y zsh

ENV SHELL /bin/zsh

RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# ctags

RUN apt-get install -y ctags

# dependency for github.com/ponylang/regex.git

RUN \
  apt-get install -y apt-utils 2>&1 | grep -v "debconf: delaying package configuration, since apt-utils is not installed" && \
  apt-get install -y --no-install-recommends libpcre2-dev

# ENV TZ=Europe/Berlin
# RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# RUN apt install \
#         gcc make \
#         pkg-config autoconf automake \
#         python3-docutils \
#         libseccomp-dev \
#         libjansson-dev \
#         libyaml-dev \
#         libxml2-dev -y
# RUN git clone https://github.com/universal-ctags/ctags.git && \
#     cd ctags && \
#     ./autogen.sh && \
#     ./configure  && \
#     make && \
#     make install && \
#     cd .. && \
#     rm -rf ctags
# RUN apt remove \
#         gcc \
#         pkg-config autoconf automake \
#         python3-docutils \
#         libseccomp-dev \
#         libjansson-dev \
#         libyaml-dev \
#         libxml2-dev -y
