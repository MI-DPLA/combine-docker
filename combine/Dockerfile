FROM combine-docker_spark-cluster-base:latest

# install miniconda
# https://hub.docker.com/r/continuumio/miniconda3/dockerfile
RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

RUN /opt/conda/bin/conda create -n combine python=3.5 --yes \
 && echo "conda activate combine" >> ~/.bashrc

# set default to python 3.5
RUN rm /usr/bin/python \
 && ln -s /usr/bin/python3.5 /usr/bin/python

# install mysql client
RUN apt-get update \
 && apt-get install -y default-libmysqlclient-dev gcc libkrb5-dev libxml2-dev libxslt1-dev libmysql-java python3-dev

# clone combine repo
RUN cd /opt \
 && git clone https://github.com/WSULib/combine.git

# downgrade pip and install dependencies
RUN pip install pip==9.0.3
RUN cd /opt/combine \
 && pip install -r requirements.txt

# install Livy Client
# https://github.com/WSULib/combine-playbook/blob/master/roles/combine/tasks/main.yml#L34-L42

# install es2csv
# https://github.com/WSULib/combine-playbook/blob/master/roles/combine/tasks/main.yml#L44-L49

# create mysql database

# run database migrations
# RUN python manage.py makemigrations \
#  && python manage.py migrate \
#  && python manage.py migrate core \
