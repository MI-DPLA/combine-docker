#echo "### BUILDLOG:  dollar-BUILDLOG is $BUILDLOG   ...ENTER to continue"

echo "### BUILDLOG:  Read .env file and set WORKDIR for config settings used hereafter" | tee -a $BUILDLOG
source ./.env
WORKDIR=$(pwd)
echo "" | tee -a $BUILDLOG

echo "### BUILDLOG:  Create static.tar; extract files from static.tar to $WORKDIR/combine/combine/static/" | tee -a $BUILDLOG
cd $WORKDIR/combine/combine
if [[ ! -d "./static/" ]]; then
    mkdir static/
fi
tar -cf static.tar ./core/static/*
mv static.tar ./static
cd ./static
tar -xf static.tar --strip=5
tar -xf static.tar --strip=4
tar -xf static.tar --strip=3
tar -xf static.tar --strip=2
tar -xf static.tar --strip=1
echo "" | tee -a $BUILDLOG

echo "### BUILDLOG:  Setup Livy" | tee -a $BUILDLOG
if [[ ! -d "$WORKDIR/external-static/livy/" ]]; then
    mkdir -p $WORKDIR/external-static/livy
fi
cd $WORKDIR/external-static/livy
svn export --force https://github.com/apache/incubator-livy/tags/$LIVY_TAGGED_RELEASE/server/src/main/resources/org/apache/livy/server/ui/static/js/ 2>&1 | sed -e 's/^/    /g' | tee -a $BUILDLOG
if [[ ! -d "$WORKDIR/external-static/spark/" ]]; then
    mkdir -p $WORKDIR/external-static/spark
fi
echo "" | tee -a $BUILDLOG

echo "### BUILDLOG:  Setup Spark" | tee -a $BUILDLOG
cd $WORKDIR/external-static/spark
svn export --force https://github.com/apache/spark/tags/v$SPARK_VERSION/core/src/main/resources/org/apache/spark/ui/static 2>&1 | sed -e 's/^/    /g' | tee -a $BUILDLOG
cd $WORKDIR
echo "" | tee -a $BUILDLOG

echo "### BUILDLOG:  Extract external-static files" | tee -a $BUILDLOG
tar -cf external-static.tar ./external-static/*
mv external-static.tar $WORKDIR/combine/combine/static
cd $WORKDIR/combine/combine/static
tar -xf external-static.tar --strip=3
tar -xf external-static.tar --strip=2
tar -xf external-static.tar --strip=1
echo "" | tee -a $BULDLOG

cd $WORKDIR
echo "###########################################################################################" | tee -a $BUILDLOG
echo "### BUILDLOG: Finished running buildstatic.sh" | tee -a $BUILDLOG
echo ""
