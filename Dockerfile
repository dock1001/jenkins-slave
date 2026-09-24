# Based on https://github.com/rancher/jenkins-slave
FROM ubuntu:26.04

# Remove 'ubuntu' user and group if they exist (frees UID/GID 1000)
RUN set -eux; \
    if getent passwd ubuntu > /dev/null; then \
        userdel -r ubuntu || true; \
    fi; \
    if getent group ubuntu > /dev/null; then \
        groupdel ubuntu || true; \
    fi

# Build tools, JDK, tini and the Docker CLI with buildx
RUN apt-get update \
 && apt-get -y install --no-install-recommends \
        ca-certificates \
        curl \
        git \
        lftp \
        openjdk-21-jdk-headless \
        rsync \
        tini \
        wget \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
 && chmod a+r /etc/apt/keyrings/docker.asc \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get -y install --no-install-recommends \
        docker-ce-cli \
        docker-buildx-plugin \
 && rm -rf /var/lib/apt/lists/*

# Agent user
ENV HOME=/home/jenkins-slave
ENV JENKINS_PERSISTENT_CACHE=$HOME/PersistentCache
ENV USER=jenkins-slave USER_ID=1000 USER_GID=1000

RUN groupadd --gid "${USER_GID}" "${USER}" \
 && useradd -c "Jenkins Slave user" -d $HOME -m $USER --uid ${USER_ID} --gid ${USER_GID}

# The swarm client is downloaded from the controller at startup (see entrypoint.sh)
RUN mkdir /var/jenkins \
 && chown jenkins-slave:jenkins-slave /var/jenkins

COPY entrypoint.sh /entrypoint.sh

USER jenkins-slave

RUN mkdir -p $JENKINS_PERSISTENT_CACHE

VOLUME ["/var/jenkins"]

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
