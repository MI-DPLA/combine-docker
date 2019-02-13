# combine-docker
Combine Docker-ized

## Initial Build

  * probably should use a prefix (namespace):
  `docker-compose -p combine-docker # else, defaults to directory name`

  * Build images:
  `docker-compose -p combine build`

  * Format HDFS namenode
  `docker-compose run hadoop-namenode /bin/bash -c "mkdir -p /hdfs/namenode && echo 'Y' | ${HADOOP_PREFIX}/bin/hdfs namenode -format"`

  * [Combine database setup from Ansible playbook](https://github.com/WSULib/combine-playbook/blob/master/roles/combine/tasks/main.yml)

## Running

  * Run with `up` and detatch:
  `docker-compose -p combine up -d`
