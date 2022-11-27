FROM ubuntu:20.04
MAINTAINER "Jorge Bernal"

ENV GO_VERSION=1.19.3
ENV OPERATOR_SDK_VERSION=1.25.0


RUN apt update -y && \
    apt-get install git wget curl gpg make vim docker.io -y && \
    wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /home/go.zip && \
    mkdir /home/go && cd /home/go && mv /home/go.zip /home/go && tar xvf go.zip && \
    rm go.zip && \
    ln -s /home/go/go/bin/go /usr/local/bin/go && \
    echo "export GOPROXY=https://proxy.golang.org|direct" >> ~/.bashrc

RUN export ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac) && \
    export OS=$(uname | awk '{print tolower($0)}') && \
    export OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/v${OPERATOR_SDK_VERSION} && \
    curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH} && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys 052996E2A20B5C7E && \
    curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt && \
    curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt.asc && \
    gpg -u "Operator SDK (release) <cncf-operator-sdk@cncf.io>" --verify checksums.txt.asc && \
    grep operator-sdk_${OS}_${ARCH} checksums.txt | sha256sum -c - && \
    chmod +x operator-sdk_${OS}_${ARCH} && mv operator-sdk_${OS}_${ARCH} /usr/local/bin/operator-sdk && \
    rm checksums.txt*

RUN cd /home && git clone https://github.com/operator-framework/java-operator-plugins.git && \
    cd java-operator-plugins && go mod tidy && make

RUN apt update -y && \
    apt-get install ca-certificates apt-transport-https -y && \
    curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt update -y && apt-get install kubectl -y

RUN export TZ=Europe/Paris && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt update -y && \
    apt-get install openjdk-11-jdk -y && \
    cd /home && mkdir maven && cd maven && wget https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz -O maven.tar.gz && \
    tar xvf maven.tar.gz && rm maven.tar.gz && \
    echo "export PATH=$PATH:/home/maven/apache-maven-3.8.6/bin" >> ~/.bashrc


RUN ["mkdir", "/home/data"]
RUN ["mkdir", "/root/.kube"]

COPY docker/kubeconfig /root/.kube/config
COPY docker/entrypoint.sh /home

CMD ["/home/entrypoint.sh"]
