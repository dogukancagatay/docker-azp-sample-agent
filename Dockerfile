FROM dcagatay/azp-agent-dind:latest

ARG UBUNTU_ARCHIVE_PROXY="http://archive.ubuntu.com/ubuntu/"
ARG UBUNTU_SECURITY_PROXY="http://security.ubuntu.com/ubuntu/"
ARG UBUNTU_DOCKER_APT_PROXY="https://download.docker.com/linux/ubuntu"
ARG AZURE_CLI_APT_PROXY="https://packages.microsoft.com/repos/azure-cli/"

RUN sed -i "s|http://archive.ubuntu.com/ubuntu/|${UBUNTU_ARCHIVE_PROXY}|g" /etc/apt/sources.list && \
  sed -i "s|http://us.archive.ubuntu.com/ubuntu/|${UBUNTU_ARCHIVE_PROXY}/|g" /etc/apt/sources.list && \
  sed -i "s|http://security.ubuntu.com/ubuntu/|${UBUNTU_SECURITY_PROXY}|g" /etc/apt/sources.list && \
  sed -i "s|https://download.docker.com/linux/ubuntu|${UBUNTU_DOCKER_APT_PROXY}|g" /etc/apt/sources.list.d/docker.list && \
  sed -i "s|https://packages.microsoft.com/repos/azure-cli/|${AZURE_CLI_APT_PROXY}|g" /etc/apt/sources.list.d/azure-cli.list

# Common packages
RUN apt-get update && apt-get install -y \
  aria2 \
  binutils \
  build-essential \
  bzip2 \
  coreutils \
  curl \
  git \
  gnupg2 \
  iputils-ping \
  jq \
  lsb-release \
  m4 \
  mercurial \
  p7zip-full \
  p7zip-rar \
  parallel \
  pkg-config \
  python-is-python3 \
  python3-dev \
  python3-pip \
  rsync \
  software-properties-common \
  sshpass \
  subversion \
  telnet \
  time \
  wget \
  xorriso \
  xz-utils \
  zip

# Install KVM and Qemu
RUN apt-get install -y \
  bridge-utils \
  cpu-checker \
  libvirt-clients \
  libvirt-daemon \
  qemu \
  qemu-kvm

## Install Java
# ARG JAVA_REPO_URL="https://packages.adoptium.net/"
# ARG JAVA_8_VERSION="8.0.322.0.0+6-1"
# ARG JAVA_11_VERSION="11.0.14.0.0+9-1"
# ARG JAVA_17_VERSION="17.0.2.0.0+8-1"
# RUN curl -fsSL --retry 3 "${JAVA_REPO_URL}artifactory/api/gpg/key/public" | apt-key add - && \
#   add-apt-repository --yes "${JAVA_REPO_URL}artifactory/deb/" && \
#   apt-get install -y temurin-8-jdk=${JAVA_8_VERSION} && \
#   apt-get install -y temurin-11-jdk=${JAVA_11_VERSION} && \
#   apt-get install -y temurin-17-jdk=${JAVA_17_VERSION}

# ENV JAVA_HOME_8_X64="/usr/lib/jvm/temurin-8-jdk-amd64"
# ENV JAVA_HOME_11_X64="/usr/lib/jvm/temurin-11-jdk-amd64"
# ENV JAVA_HOME_17_X64="/usr/lib/jvm/temurin-17-jdk-amd64"

# Install Java 8
# ARG JAVA8_DOWNLOAD_URL="https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u292-b10/OpenJDK8U-jdk_x64_linux_hotspot_8u292b10.tar.gz"
ARG JAVA8_DOWNLOAD_URL="https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u322-b06/OpenJDK8U-jdk_x64_linux_hotspot_8u322b06.tar.gz"
RUN curl -fsSL --retry 3 "${JAVA8_DOWNLOAD_URL}" -o /opt/java.tar.gz && \
  tar -xzf /opt/java.tar.gz -C /opt/ && \
  rm -rf /opt/java.tar.gz && \
  ln -s /opt/jdk8* /opt/java-8-jdk
ENV JAVA_HOME_8_X64 "/opt/java-8-jdk"

# Install Java 11
# ARG JAVA11_DOWNLOAD_URL="https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.11_9.tar.gz"
ARG JAVA11_DOWNLOAD_URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.14.1%2B1/OpenJDK11U-jdk_x64_linux_hotspot_11.0.14.1_1.tar.gz"
RUN curl -fsSL --retry 3 "${JAVA11_DOWNLOAD_URL}" -o /opt/java.tar.gz && \
  tar -xzf /opt/java.tar.gz -C /opt/ && \
  rm -rf /opt/java.tar.gz && \
  ln -s /opt/jdk-11* /opt/java-11-jdk
ENV JAVA_HOME_11_X64 "/opt/java-11-jdk"

# Install Java 17
ARG JAVA_17_DOWNLOAD_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.2%2B8/OpenJDK17U-jdk_x64_linux_hotspot_17.0.2_8.tar.gz"
RUN curl -fsSL --retry 3 "${JAVA_17_DOWNLOAD_URL}" -o /opt/java.tar.gz && \
  tar -xzf /opt/java.tar.gz -C /opt/ && \
  rm -rf /opt/java.tar.gz && \
  ln -s /opt/jdk-17* /opt/java-17-jdk
ENV JAVA_HOME_17_X64 "/opt/java-17-jdk"

ENV JAVA_HOME "${JAVA_HOME_17_X64}"

## Install Maven
ARG MAVEN_DOWNLOAD_URL="https://downloads.apache.org/maven/maven-3/3.8.5/binaries/apache-maven-3.8.5-bin.tar.gz"
RUN curl -fsSL --retry 3 "${MAVEN_DOWNLOAD_URL}" -o /opt/maven.tar.gz && \
  tar -xzf /opt/maven.tar.gz -C /opt/ && \
  rm -rf /opt/maven.tar.gz && \
  ln -s /opt/apache-maven-3.8.5 /opt/maven
ENV M2_HOME "/opt/maven"

## Install Gradle
ARG GRADLE_DOWNLOAD_URL="https://services.gradle.org/distributions/gradle-7.4.2-bin.zip"
RUN curl -fsSL --retry 3 "${GRADLE_DOWNLOAD_URL}" -o /opt/gradle.zip && \
  unzip -d /opt /opt/gradle.zip && \
  rm -rf /opt/gradle.zip && \
  ln -s /opt/gradle-7.4.2 /opt/gradle
ENV GRADLE_HOME "/opt/gradle"

# Install NodeJS
ARG NODE16_DOWNLOAD_URL="https://nodejs.org/dist/v16.13.1/node-v16.13.1-linux-x64.tar.xz"
RUN curl -fsSL --retry 3 "${NODE16_DOWNLOAD_URL}" -o /opt/nodejs.tar.xz && \
  tar -xJf /opt/nodejs.tar.xz -C /opt/ && \
  rm -rf /opt/nodejs.tar.xz && \
  ln -s /opt/node-v16.13.1-linux-x64 /opt/node-16
ENV NODE_HOME "/opt/node-16"

# Install buildah scopeo podman
ENV OPENSUSE_REPO_URL="http://download.opensuse.org/"
RUN . /etc/os-release && \
  apt-get update && \
  apt-get install -y apt-transport-https ca-certificates curl gnupg2 && \
  echo "deb ${OPENSUSE_REPO_URL}/repositories/devel:/kubic:/libcontainers:/stable/x${NAME}_${VERSION_ID}/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list && \
  curl -fSsL --retry 3 "${OPENSUSE_REPO_URL}/repositories/devel:kubic:libcontainers:stable/x${NAME}_${VERSION_ID}/Release.key" | apt-key add - && \
  apt-get update && \
  apt-get install -y buildah skopeo podman && \
  mkdir -p /etc/containers && \
  echo -e "[registries.search]\nregistries = ['docker.io', 'quay.io']" | tee /etc/containers/registries.conf

# Install yq
ARG YQ_URL=https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_amd64
RUN curl -fsSL --retry 3 -o /usr/bin/yq "${YQ_URL}" && \
  chmod +x /usr/bin/yq

# Install packer terraform
ARG HASHICORP_APT_PROXY="https://apt.releases.hashicorp.com/"
RUN curl -fsSL --retry 3 "${HASHICORP_APT_PROXY}gpg" | apt-key add - && \
  apt-add-repository "deb [arch=amd64] ${HASHICORP_APT_PROXY} $(lsb_release -cs) main" && \
  apt-get update && \
  apt-get install -y \
  packer \
  terraform

# Install kubectl
ARG KUBECTL_DOWNLOAD_URL="https://storage.googleapis.com/kubernetes-release/release/v1.23.0/bin/linux/amd64/kubectl"
RUN curl -fsSL --retry 3 -o /usr/bin/kubectl "${KUBECTL_DOWNLOAD_URL}" && \
  curl -fsSL --retry 3 -o /tmp/kubectl.sha256 "${KUBECTL_DOWNLOAD_URL}.sha256" && \
  echo "$(cat /tmp/kubectl.sha256)  /usr/bin/kubectl" | sha256sum --check && \
  chmod +x /usr/bin/kubectl

# Install helm
ARG HELM_DOWNLOAD_URL="https://get.helm.sh/helm-v3.8.1-linux-amd64.tar.gz"
RUN apt-get install -y wget ca-certificates && \
  curl -fsSL --retry 3 -o "/tmp/$(basename ${HELM_DOWNLOAD_URL})" "${HELM_DOWNLOAD_URL}" && \
  curl -fsSL --retry 3 -o "/tmp/helm.sha256sum" "${HELM_DOWNLOAD_URL}.sha256sum" && \
  cd /tmp && \
  sha256sum -c helm.sha256sum && \
  tar -xzf helm-*.tar.gz && \
  mv linux-amd64/helm /usr/local/bin && \
  rm -rf linux-amd64 helm-*.tar.gz *.sha256sum && \
  chmod +x /usr/local/bin/helm

ENV PATH "\${JAVA_HOME}/bin:\${M2_HOME}/bin:\${GRADLE_HOME}/bin:\${NODE_HOME}/bin:${PATH}"
