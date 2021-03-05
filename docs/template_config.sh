#!/usr/bin/env bash

cat > data/forum/conf/config.php <<EOF
<?php return array (
  'debug' => true,
  'database' => 
  array (
    'driver' => 'mysql',
    'host' => 'db',
    'port' => 3306,
    'database' => '$MYSQL_DATABASE',
    'username' => '$MYSQL_USER',
    'password' => '$MYSQL_PASSWORD',
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'strict' => false,
    'engine' => 'InnoDB',
    'prefix_indexes' => true,
  ),
  'url' => 'https://$HOSTNAME',
  'paths' => 
  array (
    'api' => 'api',
    'admin' => 'admin',
  ),
);
EOF
