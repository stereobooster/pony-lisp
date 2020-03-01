FROM ponylang/ponyc
RUN apt-get install -y libpcre2-dev make
COPY bundle.json ./
RUN stable fetch