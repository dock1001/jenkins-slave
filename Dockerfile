# Based on https://github.com/rancher/jenkins-slave
FROM ubuntu:25.10

# Remove 'ubuntu' user and group if they exist
RUN set -eux; \
    if getent passwd ubuntu > /dev/null; then \
        userdel -r ubuntu || true; \
    fi; \
    if getent group ubuntu > /dev/null; then \
        groupdel ubuntu || true; \
    fi

RUN apt-get update \
 && apt-get -y install \
        apt-transport-https \
        curl \
        git \
        openjdk-21-jdk \
        lftp \
        software-properties-common \
        rsync \
 && rm -rf /var/lib/apt/lists/*

# Export JAVA_HOME variable
# ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Install the Docker CLI
RUN install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
 && chmod a+r /etc/apt/keyrings/docker.asc \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get -q -y install docker-ce-cli \
 && rm -rf /var/lib/apt/lists/*

# Jenkins swarm
ENV JENKINS_SWARM_VERSION=3.50
ENV HOME=/home/jenkins-slave
ENV JENKINS_PERSISTENT_CACHE=$HOME/PersistentCache
ENV USER=jenkins-slave USER_ID=1000 USER_GID=1000

RUN groupadd --gid "${USER_GID}" "${USER}" \
 && useradd -c "Jenkins Slave user" -d $HOME -m $USER --uid ${USER_ID} --gid ${USER_GID}

RUN curl --create-dirs -sSLo $HOME/swarm-client-$JENKINS_SWARM_VERSION.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar \
 && mkdir /var/jenkins \
 && chown jenkins-slave:jenkins-slave /var/jenkins

COPY entrypoint.sh /entrypoint.sh

USER jenkins-slave

RUN mkdir -p $JENKINS_PERSISTENT_CACHE

#ENV JENKINS_USERNAME jenkins
#ENV JENKINS_PASSWORD jenkins
#ENV JENKINS_MASTER http://jenkins:8080

VOLUME ["/var/jenkins"]

ENTRYPOINT ["/entrypoint.sh"]
