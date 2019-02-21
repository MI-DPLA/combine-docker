FROM combine-docker_spark-cluster-base:latest

# install miniconda
# https://hub.docker.com/r/continuumio/miniconda3/dockerfile
RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git default-libmysqlclient-dev gcc libkrb5-dev libxml2-dev libxslt1-dev libmysql-java python3-dev mysql-client vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

# create combine conda env and set to path
RUN /opt/conda/bin/conda create -n combine python=3.5 --yes
ENV PATH /opt/conda/envs/combine/bin:$PATH

# clone combine repo
RUN cd /opt \
 && git clone https://github.com/WSULib/combine.git \
 && cd combine \
 && git checkout dockerized

# Copy configurations and scripts
COPY localsettings.py /opt/combine/combine/localsettings.py
COPY combine.sql /tmp/combine.sql
COPY combine_db_prepare.sh /tmp/combine_db_prepare.sh

# downgrade pip and install dependencies
RUN pip install pip==9.0.3
RUN cd /opt/combine \
 && pip install -r requirements.txt

# install Livy Client
# https://github.com/WSULib/combine-playbook/blob/master/roles/combine/tasks/main.yml#L34-L42
# Arguments
ARG LIVY_TAGGED_RELEASE
ARG SCALA_VERSION
ENV LIVY_TAGGED_RELEASE=$LIVY_TAGGED_RELEASE
ENV SCALA_VERSION=$SCALA_VERSION
RUN cd /tmp \
 && git clone https://github.com/apache/incubator-livy livy_for_python_client \
 && cd livy_for_python_client \
 && git checkout -b tags/${LIVY_TAGGED_RELEASE} ${LIVY_TAGGED_RELEASE} \
 && cd /tmp/livy_for_python_client/python-api \
 && python setup.py install
