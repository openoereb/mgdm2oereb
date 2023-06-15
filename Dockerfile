FROM ubuntu:22.04

ARG GEOLINK2OEREB_VERSION="0.1.2"
RUN apt update && \
    apt install -y xsltproc \
      default-jdk \
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
    pip install geolink2oereb[recommend]==${GEOLINK2OEREB_VERSION}

ARG ILIVALIDATOR_VERSION=1.13.3
RUN curl -o /tmp/ilivalidator-${ILIVALIDATOR_VERSION}.zip https://downloads.interlis.ch/ilivalidator/ilivalidator-${ILIVALIDATOR_VERSION}.zip && \
    mkdir /ilivalidator && \
    unzip -d /ilivalidator /tmp/ilivalidator-${ILIVALIDATOR_VERSION}.zip && \
    ln -s /ilivalidator/ilivalidator-${ILIVALIDATOR_VERSION}.jar /ilivalidator/ilivalidator.jar && \
    chmod -R ogu+rwx /ilivalidator/* && \
    rm -rf /tmp/ilivalidator-${ILIVALIDATOR_VERSION}.zip

<<<<<<< Updated upstream
=======
ARG GEOLINK2OEREB_VERSION="0.1.9"
RUN pip install geolink2oereb[recommend]==${GEOLINK2OEREB_VERSION} c2c.template==2.3.0

>>>>>>> Stashed changes
WORKDIR /app
