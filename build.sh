shopt -s execfail
fnc() { echo Encountered a problem! Please resolve issue or contact support.; exit 1;}
trap fnc ERR

docker-compose -v
docker -v
svn --version

echo "Running Combine-Docker build script.  Note: this may take some time, anywhere from 5-20 minutes depending on your hardware."

# source .env file
source ./.env
WORKDIR=$(pwd)

# bring down Combine docker containers, if running
docker-compose down
echo $COMBINE_BRANCH

# init Combine app submodule and use localsettings docker template
git submodule init
git submodule update
cd $WORKDIR/combine/combine
git fetch
git checkout $COMBINE_BRANCH
git pull
if [[ ! -f "./combine/localsettings.py" ]]; then
    cp ./combine/localsettings.py.docker ./combine/localsettings.py
fi
cd $WORKDIR

# build images
docker volume rm combine_python_env hadoop_binaries spark_binaries livy_binaries combine_tmp
docker-compose build

# format Hadoop namenode
docker-compose run hadoop-namenode /bin/bash -c "mkdir -p /hdfs/namenode"
docker-compose run hadoop-namenode /bin/bash -c "echo 'Y' | /opt/hadoop/bin/hdfs namenode -format"

# Combine db migrations and superuser create
docker-compose run combine-django /bin/bash -c "bash /tmp/combine_db_prepare.sh"

if [[ ! -d "$WORKDIR/combine/combine/static/js/" ]]; then
  mkdir -p $WORKDIR/combine/combine/static/js/
fi
cp -r $WORKDIR/combine/combine/core/static/* static/
cp -r $WORKDIR/combine/combine/static/[^j]*/*.js static/js/
if [[ ! -d "$WORKDIR/external-static/livy/" ]]; then
  mkdir -p $WORKDIR/external-static/livy
fi
cd $WORKDIR/external-static/livy
svn export --force https://github.com/apache/incubator-livy/tags/$LIVY_TAGGED_RELEASE/server/src/main/resources/org/apache/livy/server/ui/static/js/
cp ./js/*.js $WORKDIR/combine/combine/static/js/
if [[ ! -d "$WORKDIR/external-static/spark/" ]]; then
  mkdir -p $WORKDIR/external-static/spark
fi
cd $WORKDIR/external-static/spark
svn export --force https://github.com/apache/spark/tags/v$SPARK_VERSION/core/src/main/resources/org/apache/spark/ui/static
cp ./static/*.js $WORKDIR/combine/combine/static/
cd $WORKDIR
