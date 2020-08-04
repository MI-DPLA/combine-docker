echo "Running Combine-Docker build script.  Note: this may take some time, anywhere from 5-20 minutes depending on your hardware."

# source .env file
source ./.env
WORKDIR=$(pwd)

# bring down Combine docker containers, if running
docker-compose down
touch $WORKDIR/nginx/error.log
if [[ ! -f "$WORKDIR/nginx/nginx.conf" ]]; then
  cp $WORKDIR/nginx/nginx.conf.template $WORKDIR/nginx/nginx.conf
fi

# init Combine app submodule and use localsettings docker template
echo $COMBINE_BRANCH
git submodule init
git submodule update
cd $WORKDIR/combine/combine
git fetch
git checkout $COMBINE_BRANCH
git pull
if [[ ! -f "./combine/localsettings.py" ]]; then
    cp ./combine/localsettings.py.docker ./combine/localsettings.py
fi
sed -i 's/3306/3307/' ./combine/settings.py # mysql port is 3307 in docker, 3306 by default

if [[ ! -d "$WORKDIR/combine/combine/static/js/" ]]; then
  mkdir -p $WORKDIR/combine/combine/static/js/
fi
cd $WORKDIR

# build images
docker volume rm combine-docker_combine_python_env combine-docker_hadoop_binaries combine-docker_spark_binaries combine-docker_livy_binaries combine-docker_combine_tmp combine-docker_combinelib
docker-compose build

# format Hadoop namenode
docker-compose run hadoop-namenode /bin/bash -c "mkdir -p /hdfs/namenode"
docker-compose run hadoop-namenode /bin/bash -c "echo 'Y' | /opt/hadoop/bin/hdfs namenode -format"

# Combine db migrations and superuser create
docker-compose run combine-django /bin/bash -c "bash /tmp/combine_db_prepare.sh"

$WORKDIR/buildstatic.sh
