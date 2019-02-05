# combine-docker
Combine Docker-ized

## Initial Build

  * probably should use a prefix (namespace):
  `docker-compose -p combine`

  * Build images:
  `docker-compose -p combine build`

  * [Combine database setup from Ansible playbook](https://github.com/WSULib/combine-playbook/blob/master/roles/combine/tasks/main.yml)

## Running

  * Run with `up` and detatch:
  `docker-compose -p combine up -d`
