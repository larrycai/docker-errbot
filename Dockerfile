# Errbot - the pluggable chatbot

FROM ubuntu:xenial

# MAINTAINER Rafael Römhild <rafael@roemhild.de>
MAINTAINER Larry Cai <larry.caiyu@gmail.com

ENV ERR_USER err
ENV DEBIAN_FRONTEND noninteractive
ENV PATH /app/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Add err user and group
RUN groupadd -r $ERR_USER \
    && useradd -r \
       -g $ERR_USER \
       -d /srv \
       $ERR_USER

# Install packages and perform cleanup
RUN apt-get update \
  && apt-get -y install --no-install-recommends \
         git \
         qalc \
         locales \
         dnsutils \
         libssl-dev \
         build-essential \
         python3-dnspython \
         python3-dev \
         python3-openssl \
         python3-pip \
         python3-cffi \
         python3-pyasn1 \
         python3-geoip \
         python3-lxml \
         python3-cryptography \
         language-pack-en-base \
    && dpkg-reconfigure locales \
    && pip3 install virtualenv \
    && pip3 install -U setuptools \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir /srv/data /srv/plugins /srv/errbackends /app \
    && chown -R $ERR_USER: /srv /app

USER $ERR_USER
WORKDIR /srv

COPY requirements.txt /app/requirements.txt

RUN virtualenv /app/venv
RUN . /app/venv/bin/activate; pip install --no-cache-dir -r /app/requirements.txt

COPY config.py /app/config.py
COPY run.sh /app/venv/bin/run.sh

EXPOSE 3141 3142
VOLUME ["/srv"]

CMD ["/app/venv/bin/run.sh"]
