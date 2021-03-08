#!/usr/bin/env bash
cd /app || exit
php flarum websockets:serve
