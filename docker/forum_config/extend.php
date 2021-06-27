<?php

/*
 * This file is part of Flarum.
 *
 * For detailed copyright and license information, please view the
 * LICENSE file that was distributed with this source code.
 */

use Flarum\Extend;

return [
    (new Blomstra\Redis\Extend\Redis([
        'host' => 'redis',
        'password' => getenv('REDIS_PASS'),
        'port' => 6379,
        'database' => 1,
    ]))->disable(['session'])
    ->useDatabaseWith('cache', 3)
    ->useDatabaseWith('queue', 4)
//  ->useDatabaseWith('session', 5)
];
