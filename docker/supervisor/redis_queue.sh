#!/usr/bin/env bash
cd /app || exit
php flarum queue:work redis
