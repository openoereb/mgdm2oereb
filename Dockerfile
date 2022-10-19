FROM ubuntu:22.04

RUN apt update && \
    apt install -y xsltproc \
      git \
      make \
      curl \
      unzip \
      parallel \
      python3 \
      python3-lxml \
      python3-requests

WORKDIR /app
