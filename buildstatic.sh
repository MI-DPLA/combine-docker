source ./.env
WORKDIR=$(pwd)

cd $WORKDIR/combine/combine
if [[ ! -d "./static/" ]]; then
  mkdir static/
fi
tar -cvf static.tar ./core/static/*
mv static.tar ./static
cd ./static
tar -xvf static.tar --strip=5
tar -xvf static.tar --strip=4
tar -xvf static.tar --strip=3
tar -xvf static.tar --strip=2
tar -xvf static.tar --strip=1
if [[ ! -d "$WORKDIR/external-static/livy/" ]]; then
  mkdir -p $WORKDIR/external-static/livy
fi
cd $WORKDIR/external-static/livy
svn export --force https://github.com/apache/incubator-livy/tags/$LIVY_TAGGED_RELEASE/server/src/main/resources/org/apache/livy/server/ui/static/js/
if [[ ! -d "$WORKDIR/external-static/spark/" ]]; then
  mkdir -p $WORKDIR/external-static/spark
fi
cd $WORKDIR/external-static/spark
svn export --force https://github.com/apache/spark/tags/v$SPARK_VERSION/core/src/main/resources/org/apache/spark/ui/static
cd $WORKDIR
tar -cvf external-static.tar ./external-static/*
mv external-static.tar $WORKDIR/combine/combine/static
cd $WORKDIR/combine/combine/static
tar -xvf external-static.tar --strip=3
tar -xvf external-static.tar --strip=2
tar -xvf external-static.tar --strip=1
cd $WORKDIR
