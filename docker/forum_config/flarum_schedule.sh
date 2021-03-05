# hc_schedule from healthcheck.io should be available in environment
healthcheck_address="$hc_schedule"

if [ -z ${healthcheck_address+x} ]; then
  (
    cd /app && php flarum schedule:run
  ) &> /dev/null
else
  (
    cd /app && php flarum schedule:run
  ) &> /dev/null && curl --silent --retry 3 -m 10 "$healthcheck_address" 1> /dev/null
fi
