FROM ponylang/ponyc

RUN apt install zsh -y

ENV SHELL /bin/zsh

RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN apt-get install ctags

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
