<?php return array (
  'debug' => env('DEBUG', 'false'),
  'poweredByHeader' => true,
  'database' =>
  array (
    'driver' => env('DB_CLIENT', 'mysql'),
    'host' => env('DB_HOST', 'localhost'),
    'port' => env('DB_PORT', '3306'),
    'database' => env('DB_NAME', 'envDefaultDbName'),
    'username' => env('DB_USER', 'envDefaultUser'),
    'password' => env('DB_PASS', 'envDefaultPass'),
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'strict' => false,
    'engine' => 'InnoDB',
    'prefix_indexes' => true,
  ),
  'url' => 'https://' . env('HOSTNAME', 'localhost'),
  'paths' =>
  array (
    'api' => 'api',
    'admin' => 'admin',
  ),
  'websocket' => [
    'server-port' => env('FLARUM_WEBSOCKET_PORT', '6001'),
    'js-client-port' => '443',
    'php-client-host' => '127.0.0.1',
    'php-client-port' => '6001',
    'php-client-secure' => false
  ],
);
