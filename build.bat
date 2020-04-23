echo "Running Combine-Docker build script.  Note: this may take some time, anywhere from 5-20 minutes depending on your hardware."
setlocal enableextensions
set combine_branch="dev"
set workdir=%cd%
set livy_tagged_release="v0.6.0-incubating"
set spark_version="2.3.2"

rem bring down Combine docker containers, if running
docker-compose down
echo. > %workdir%\nginx\error.log

rem init Combine app submodule and use localsettings docker template
echo %combine_branch%
git submodule init
git submodule update
cd %workdir%\combine\combine
git fetch
git checkout %combine_branch%
git pull
if not exist "%cd%\combine\localsettings.py" (
    copy %cd%\combine\localsettings.py.docker %cd%\combine\localsettings.py
)

cd %workdir%

rem build images
docker volume rm combine_python_env hadoop_binaries spark_binaries livy_binaries combine_tmp
docker-compose build

rem format Hadoop namenode
docker-compose run hadoop-namenode /bin/bash -c "mkdir -p /hdfs/namenode"
docker-compose run hadoop-namenode /bin/bash -c "echo 'Y' | /opt/hadoop/bin/hdfs namenode -format"

rem Combine db migrations and superuser create
docker-compose run combine-django /bin/bash -c "bash /tmp/combine_db_prepare.sh"

cd %workdir%\combine\combine
if not exist "%cd%\static\js\" (
  md %cd%\static\js\
)
robocopy /s %cd%\core\static\* static\
if not exist "%workdir%\external-static\livy\" (
  md %workdir%\external-static\livy
)
cd %workdir%\external-static\livy
svn export --force https://github.com/apache/incubator-livy/tags/%livy_tagged_release%/server/src/main/resources/org/apache/livy/server/ui/static/js/
robocopy /s %cd%\js\* %workdir%\combine\combine\static\js\
if not exist "%workdir%\external-static\spark\" (
  md %workdir%\external-static\spark
)
cd %workdir%\external-static\spark
svn export --force https://github.com/apache/spark/tags/v%spark_version%/core/src/main/resources/org/apache/spark/ui/static
robocopy /s %cd%\static\* %workdir%\combine\combine\static\
cd %workdir%\combine\combine\static
for /r %f in (*) do @copy "%f" .
copy *.js %cd%\js
