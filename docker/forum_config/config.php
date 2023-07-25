<?php return array (
  'debug' => getenv('DEBUG') ?: false,
  'poweredByHeader' => true,
  'database' =>
  array (
    'driver' => getenv('DB_DRIVER') ?: 'mysql',
    'host' => getenv('DB_HOST') ?: 'localhost',
    'port' => getenv('DB_PORT') ?: '3306',
    'database' => getenv('DB_NAME') ?: 'getenvDefaultDbName',
    'username' => getenv('DB_USER') ?: 'getenvDefaultUser',
    'password' => getenv('DB_PASS') ?: 'getenvDefaultPass',
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'strict' => false,
    'engine' => 'InnoDB',
    'prefix_indexes' => true,
  ),
  'url' => 'https://' . getenv('HOSTNAME') ?: 'localhost',
  'paths' =>
  array (
    'api' => 'api',
    'admin' => 'admin',
  ),
  'websocket' => [
    'server-port' => getenv('FLARUM_WEBSOCKET_PORT') ?: '6001',
    'js-client-port' => '443',
    'php-client-host' => '127.0.0.1',
    'php-client-port' => '6001',
    'php-client-secure' => false
  ],
);
