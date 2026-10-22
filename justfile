set dotenv-load

start:
  #!/usr/bin/env bash
  mkdir -p _data/redis/conf
  if [ ! -f _data/redis/conf/redis.conf ]; then
    sudo chown $(whoami) _data/redis/conf
    cp docs/redis.example _data/redis/conf/redis.conf
  fi
  docker-compose up -d --remove-orphans
stop:
  docker-compose down
enter:
  #!/usr/bin/env bash
  docker-compose exec forum bash

  FORUM=$(docker inspect -f '{{ "{{" }} .Name {{ "}}" }}' $(docker-compose ps -q forum) | cut -c2-)
  tmpfile="$(mktemp)"
  docker container cp ${FORUM}:/app/composer.json "$tmpfile"
  diff docker/composer.json "$tmpfile" | grep -E '^>'
  rm "$tmpfile"
update:
    #!/usr/bin/env bash
    FORUM=$(docker inspect -f '{{ "{{" }} .Name {{ "}}" }}' $(docker-compose ps -q forum) | cut -c2-)
    docker container cp ${FORUM}:/app/composer.json docker/composer.json
    docker container cp ${FORUM}:/app/composer.lock docker/composer.lock
    git diff -U0 docker/composer.json | grep -E '^[+-] ' || true
loadsql file:
  #!/usr/bin/env bash
  set -xv
  gzip -dc {{file}} | docker compose exec -T db mariadb --user=$MYSQL_USER --password="$MYSQL_PASSWORD" $MYSQL_DATABASE
  if [ ! -f _data/forum/conf/config.php ]; then docs/template_config.sh; fi
deploy:
  #!/usr/bin/env bash

  cd docker/
  version="$(git rev-parse --short HEAD)"
  build_date="$(date '+%m_%d_%Y')"
  reponame=ledstrain-docker
  docker image build --target production \
    --build-arg GIT_COMMIT="$version" \
    --build-arg EXTIVERSE_TOKEN="$EXTIVERSE_TOKEN" \
    -t docker.sandcatdev.com/server/$reponame:build_${build_date} .
  docker image tag docker.sandcatdev.com/server/$reponame:build_${build_date} \
    docker.sandcatdev.com/server/$reponame:latest
  for i in docker.sandcatdev.com/server/$reponame:{build_${build_date},latest};
  do
    docker image push $i;
  done
