# combine-docker

## Configuration

Where will this happen?  How can this most closely align with 

## Initial Build

The end goal is a single `docker-compose up`, but in the interim there might be a couple additional steps.

Build images:
```
docker-compose -p combine-docker build
```

Format HDFS namenode:
```
docker-compose run hadoop-namenode /bin/bash -c "mkdir -p /hdfs/namenode && echo 'Y' | ${HADOOP_PREFIX}/bin/hdfs namenode -format"
```

Run Combine Django database migrations:
```
TODO
```




## Running

  * Run with `up` and detatch:
  `docker-compose -p combine up -d`
