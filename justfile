start:
  docker-compose up -d
stop:
  docker-compose down
enter:
  #!/usr/bin/env bash
  just start
  docker-compose exec forum bash
  git diff -U0 docker/composer.json | grep -E '^[+-] ' || true
update:
    #!/usr/bin/env bash
    FORUM=$(docker inspect -f '{{ "{{" }} .Name {{ "}}" }}' $(docker-compose ps -q forum) | cut -c2-)
    docker container cp ${FORUM}:/app/composer.json docker/composer.json
    docker container cp ${FORUM}:/app/composer.lock docker/composer.lock
    git diff -U0 docker/composer.json | grep -E '^[+-] ' || true
loadsql file:
  #!/usr/bin/env bash
  gzip -dc {{file}} | docker-compose exec -T db mysql --user=$MYSQL_USER --password="$MYSQL_PASSWORD" $MYSQL_DATABASE
  if [ ! -f data/forum/conf/config.php ]; then docs/template_config.sh; fi
build:
  #!/usr/bin/env bash
  (
    cd docker
    docker image build -t "$REGISTRY_LOCATION" .
    docker image push "$REGISTRY_LOCATION"
  )
save-config:
    drone sign $REPO --save
