#!/bin/bash

# get datetime when script is run; use this for logfile names
RUNDATE=`date +%Y-%m-%d_%H-%m-%S`
WORKDIR=$(pwd)

# source .env file
source ./.env

# we will log output in output files in subdirectories named according to date-time of build run
if [ ! -d $WORKDIR/buildlogs ]
then
    mkdir $WORKDIR/buildlogs
fi
BUILDLOGDIR=$WORKDIR/buildlogs/build-log_$RUNDATE
mkdir $BUILDLOGDIR
BUILDLOG=$BUILDLOGDIR/build-log_$RUNDATE.log

echo ""
echo ""

echo "####################################################################################################"
echo "### BUILDLOG:  Running Combine-Docker build script. "
echo "### BUILDLOG:  Note: this may take some time, depending on your hardware and remote server response"
echo "### BUILDLOG"
echo "### BUILDLOG:  Base install directory (WORKDIR) is:  $WORKDIR" | tee -a $BUILDLOG
echo "### BUILDLOG:  " | tee -a $BUILDLOG
echo "### BUILDLOG:  To see logs as they're created:  tail -f $BUILDLOG "
echo "### BUILDLOG:"
echo "### BUILDLOG:  hit ENTER to continue..."
read ANSWER
echo "### BUILDLOG:  Base install directory (WORKDIR) is:  $WORKDIR" | tee -a $BUILDLOG


# bring down Combine docker containers, if running
echo "### BUILDLOG:  Bringing down Docker containers (if they're running)"  | tee -a $BUILDLOG
docker-compose down

# basic setup for nginx
touch $WORKDIR/nginx/error.log
if [[ ! -f "$WORKDIR/nginx/nginx.conf" ]]; then
  cp $WORKDIR/nginx/nginx.conf.template $WORKDIR/nginx/nginx.conf
fi

echo "### BUILDLOG:  Current COMBINE_BRANCH is:  $COMBINE_BRANCH"

# init Combine app submodule and use localsettings docker template
echo "### BUILDLOG:     Initializing Combine app submodule" 2>&1 | tee -a $BUILDLOG
echo "### BUILDLOG:     Working with Combine git branch:  $COMBINE_BRANCH" 2>&1 | tee -a $BUILDLOG

git submodule init   2>&1 | tee -a $BUILDLOG
git submodule update 2>&1 | tee -a $BUILDLOG

echo "### BUILDLOG:  Fetching desired Combine git branch" 2>&1 | tee -a $BUILDLOG
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
echo 
echo 
echo "### BUILDLOG:  Removing existing Docker images" 2>&1 | tee -a $BUILDLOG
docker volume rm combine-docker_combine_python_env combine-docker_hadoop_binaries combine-docker_spark_binaries combine-docker_livy_binaries combine-docker_combine_tmp combine-docker_combinelib
docker-compose build  | tee -a $BUILDLOG

echo  2>&1 | tee -a $BUILDLOG

# format Hadoop namenode
echo "### BUILDLOG:  formatting hadoop-namenode" 2>&1 | tee -a $BUILDLOG
docker-compose run hadoop-namenode /bin/bash -c "mkdir -p /hdfs/namenode"  1>>$BUILDLOG 2>&1
docker-compose run hadoop-namenode /bin/bash -c "echo 'Y' | /opt/hadoop/bin/hdfs namenode -format"  1>>$BUILDLOG 2>&1


# Combine db migrations and superuser create
echo "### BUILDLOG:  Combine db migrations and creation of superuser" 2>&1 | tee -a $BUILDLOG
docker-compose run combine-django /bin/bash -c "bash /tmp/combine_db_prepare.sh"

echo "### BUILDLOG:  Passing control to buildstatic.sh" 2>&1 | tee -a $BUILDLOG
$WORKDIR/buildstatic.sh
