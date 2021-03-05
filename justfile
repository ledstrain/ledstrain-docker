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
