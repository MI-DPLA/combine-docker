WORKDIR=$(pwd)
source ./.env

cd $WORKDIR/combine/combine
if [[ ! -d "./static/js/" ]]; then
  mkdir -p static/js/
fi
cp -r ./core/static/* static/
cp -r ./static/[^j]*/*.js static/js/
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
cp ./static/*.js $WORKDIR/combine/combine/static/js/
cp ./static/*.map $WORKDIR/combine/combine/static/js/
cd $WORKDIR
