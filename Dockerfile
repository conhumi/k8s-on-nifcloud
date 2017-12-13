FROM centos:7

RUN yum -y install \
    git \
    gcc \
    epel-release \
    bash-completion 

RUN yum -y install \
    python-pip \
    python-devel

COPY . /root
WORKDIR /root
RUN pip install -r requirements.txt && \
    ansible-galaxy install -r requirements.yml

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(\
    curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt\
    )/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/.

