echo "Running Combine-Docker post-build script"

# source .env file
source .env

# init Combine app submodule and use localsettings docker template
git submodule init
git submodule update
git -C combine/combine checkout $COMBINE_BRANCH
cp ./combine/combine/combine/localsettings.py.docker ./combine/combine/combine/localsettings.py

# build images
docker volume rm combine_python_env hadoop_binaries spark_binaries livy_binaries combine_tmp
docker-compose build

# format Hadoop namenode
docker-compose run hadoop-namenode /bin/bash -c "mkdir -p /hdfs/namenode && echo 'Y' && /opt/hadoop/bin/hdfs namenode -format"

# Combine db migrations and superuser create
docker-compose run combine-django /bin/bash -c "bash /tmp/combine_db_prepare.sh"
