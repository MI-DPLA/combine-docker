FROM combine-docker_spark-cluster-base:latest

# Arguments
ARG COMBINE_BRANCH
ENV COMBINE_BRANCH=$COMBINE_BRANCH

# install miniconda
# https://hub.docker.com/r/continuumio/miniconda3/dockerfile
RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git default-libmysqlclient-dev libmariadbclient-dev gcc libkrb5-dev libxml2-dev libxslt1-dev libmariadb-java python3-dev default-mysql-client vim make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/lib/x86_64-linux-gnu/libmariadb.so.3 /usr/lib/x86_64-linux-gnu/libmariadbclient.so.18

RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

# create combine conda env and set to path
RUN /opt/conda/bin/conda create -n combine python=3.7 --yes
ENV PATH /opt/conda/envs/combine/bin:$PATH

# copy Combine app submodule
COPY combine/combine /opt/combine/
COPY combinelib/mysql.jar /combinelib/

# Copy scripts
COPY combine/combine.sql /tmp/combine.sql
COPY combine/combine_db_prepare.sh /tmp/combine_db_prepare.sh
COPY mysql/root.my.cnf /etc/.my.cnf

# downgrade pip and install dependencies
RUN pip install pip==9.0.3
RUN cd /opt/combine \
 && pip install -r requirements.txt

# install Livy Client
# https://github.com/MI-DPLA/combine-playbook/blob/master/roles/combine/tasks/main.yml#L34-L42
# Arguments
ARG LIVY_TAGGED_RELEASE
ARG SCALA_VERSION
ENV LIVY_TAGGED_RELEASE=$LIVY_TAGGED_RELEASE
ENV SCALA_VERSION=$SCALA_VERSION
RUN pip install livy

# install ElasticDump
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
 && apt-get install -y nodejs \
 && npm install elasticdump -g

# install es2csv
RUN pip install git+https://github.com/MI-DPLA/es2csv.git@python3

# install mongo tools
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E52529D4 \
  && echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list \
  && apt-get update \
  && apt-get install -y mongodb-org-tools
