FROM ubuntu:22.04

ARG GEOLINK2OEREB_VERSION="0.1.1"
RUN apt update && \
    apt install -y xsltproc \
      git \
      libpq-dev \
      make \
      curl \
      unzip \
      parallel \
      python3 \
      python3-lxml \
      python3-requests \
      python3-pip && \
    pip install geolink2oereb[recommend]==0.1.1

WORKDIR /app
