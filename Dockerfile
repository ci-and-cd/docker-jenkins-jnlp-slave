
FROM cirepo/bionic-cibase:latest


# ------------------------------ see also: jenkinsci/docker-slave ------------------------------
LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="3.20"


ARG IMAGE_ARG_APT_MIRROR
ARG IMAGE_ARG_USER
ARG IMAGE_ARG_VERSION

ARG IMAGE_ARG_AGENT_WORKDIR=/home/${IMAGE_ARG_USER:-ubuntu}/agent


ENV AGENT_WORKDIR=${IMAGE_ARG_AGENT_WORKDIR}
ENV HOME /home/${IMAGE_ARG_USER:-ubuntu}


RUN sudo curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${IMAGE_ARG_VERSION:-3.20}/remoting-${IMAGE_ARG_VERSION:-3.20}.jar \
  && sudo chmod 755 /usr/share/jenkins \
  && sudo chmod 644 /usr/share/jenkins/slave.jar \
  && sudo mkdir /home/${IMAGE_ARG_USER:-ubuntu}/.jenkins && sudo chown ${IMAGE_ARG_USER:-ubuntu}:${IMAGE_ARG_USER:-ubuntu} /home/${IMAGE_ARG_USER:-ubuntu}/.jenkins \
  && sudo mkdir -p ${IMAGE_ARG_AGENT_WORKDIR} && sudo chown ${IMAGE_ARG_USER:-ubuntu}:${IMAGE_ARG_USER:-ubuntu} ${IMAGE_ARG_AGENT_WORKDIR}


VOLUME /home/${IMAGE_ARG_USER:-ubuntu}/.jenkins
VOLUME ${IMAGE_ARG_AGENT_WORKDIR}
WORKDIR /home/${IMAGE_ARG_USER:-ubuntu}
# ------------------------------ see also: jenkinsci/docker-slave ------------------------------


# ------------------------------ see also: jenkinsci/jnlp-slave ------------------------------
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
ENV PATH /usr/local/bin:${PATH}
ENTRYPOINT ["entrypoint.sh"]
# ------------------------------ see also: jenkinsci/jnlp-slave ------------------------------


# install netstat to allow connection health check with
# netstat -tan | grep ESTABLISHED
RUN set -ex \
  && sudo sed -i "s/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/${IMAGE_ARG_APT_MIRROR:-archive.ubuntu.com}\/ubuntu\//g" /etc/apt/sources.list \
  && sudo apt-get -y --allow-unauthenticated update \
  && sudo apt-get -y install net-tools \
  && sudo apt-get -q -y autoremove \
  && sudo apt-get -q -y clean && sudo rm -rf /var/lib/apt/lists/* && sudo rm -f /var/cache/apt/*.bin
