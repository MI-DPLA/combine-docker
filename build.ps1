<<<<<<< HEAD
$location = Location
$env = Get-Content "$location\.env" | Out-String | ConvertFrom-StringData
$env
git config --global core.eol "lf"
git config --global core.autocrlf "false"

docker-compose down
if(Test-Path $location\nginx\error.log) {
  (Get-ChildItem $location\nginx\error.log).LastWriteTime = Get-Date
} else {
  echo $null > $location\nginx\error.log
}
git submodule init
git submodule update
pushd $location\combine\combine
git fetch
git checkout $env.COMBINE_BRANCH
git pull
if (!(Test-Path ".\combine\localsettings.py")) {
  copy .\combine\localsettings.py.docker .\combine\localsettings.py
}
if (!(Test-Path ".\static\js")) {
  mkdir .\static\js
}
popd
docker volume rm combine-docker_combine_python_env combine-docker_hadoop_binaries combine-docker_spark_binaries combine-docker_livy_binaries combine-docker_combine_tmp
docker-compose build
docker-compose run hadoop-namenode /bin/bash -c "mkdir -p /hdfs/namenode"
docker-compose run hadoop-namenode /bin/bash -c "echo 'Y' | /opt/hadoop/bin/hdfs namenode -format"
docker-compose run combine-django /bin/bash -c "bash /tmp/combine_db_prepare.sh"

copy -Recurse .\combine\combine\core\static\* .\static\

if (!(Test-Path ".\external-static\livy")) {
  mkdir .\external-static\livy
}
pushd .\external-static\livy\
git init
git remote add -f origin https://github.com/apache/incubator-livy/
git config core.sparseCheckout true
$livy_path = "server/src/main/resources/org/apache/livy/server/ui/static/js/*"
echo $livy_path | out-file -encoding ascii .git/info/sparse-checkout
git pull origin $env.LIVY_TAGGED_RELEASE
copy .\$livy_path $location\combine\combine\static\
popd

if (!(Test-Path ".\external-static\spark")) {
  mkdir .\external-static\spark
}
pushd .\external-static\spark\
git init
git remote add -f origin https://github.com/apache/spark
git config core.sparseCheckout true
$spark_path = "core/src/main/resources/org/apache/spark/ui/static/*"
echo $spark_path | out-file -encoding ascii .git/info/sparse-checkout
git pull origin $env.SPARK_GIT
copy $spark_path $location\combine\combine\static
popd

pushd $location\combine\combine\static
Get-ChildItem . -recurse -File | foreach($_) {
  cp $_.Fullname ("."+$_.name) -Verbose
}
popd
