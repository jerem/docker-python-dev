FROM debian:jessie
MAINTAINER Jérémy Bethmont <jeremy.bethmont@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONUNBUFFERED 1

# Install system dependencies
RUN apt-get update -q && apt-get install -qy \
    build-essential \
    git \
    libcairo2 \
    libffi-dev \
    libglib2.0-0 \
    libgdk-pixbuf2.0-0 \
    libldap2-dev \
    libpango1.0-0 \
    libpq-dev \
    libsasl2-dev \
    libxml2-dev \
    libxslt1-dev \
    locales \
    locales-all \
    mercurial \
    openssh-server \
    postgresql-client \
    python2.7 \
    python2.7-dev \
    python-setuptools \
    shared-mime-info

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Get the latest version of pip with wheel support
RUN easy_install pip
# Install the latest version of virtualenv
RUN pip install virtualenv

# Setup SSHD for python remote debugging
RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    echo 'KexAlgorithms=diffie-hellman-group1-sha1' >> /etc/ssh/sshd_config

COPY entrypoint.sh /entrypoint.sh

RUN mkdir /app
RUN mkdir /venv
RUN mkdir /pipcache

WORKDIR /app

VOLUME /venv
VOLUME /pipcache

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]