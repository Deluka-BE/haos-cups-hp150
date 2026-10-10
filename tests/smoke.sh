#!/bin/sh
set -eu
image=${1:-haos-cups-hp150:test}
name=haos-cups-smoke-$$
volume=$name-data
cleanup() {
    docker rm -f "$name" >/dev/null 2>&1 || true
    docker volume rm "$volume" >/dev/null 2>&1 || true
}
trap cleanup EXIT HUP INT TERM
docker volume create "$volume" >/dev/null
# This fixed password is only a test fixture in an isolated container.
docker run --rm -v "$volume:/data" --entrypoint sh "$image" -c \
    'printf "%s\\n" "{\"admin_password\":\"smoke-fixture\"}" > /data/options.json'
start() {
    docker run -d --name "$name" -v "$volume:/data" "$image" >/dev/null
    ready=false
    for attempt in $(seq 1 30); do
        if docker exec "$name" healthcheck.sh >/dev/null 2>&1; then
            ready=true
            break
        fi
        sleep 1
    done
    if [ "$ready" != true ]; then
        docker logs "$name"
        exit 1
    fi
}
start
docker exec "$name" driver-check.sh
docker exec "$name" sh -c \
    'test "$(curl -ks -o /dev/null -w "%{http_code}" https://localhost:631/admin/)" = 401'
docker exec "$name" sh -c \
    'test "$(curl -ks -u cupsadmin:smoke-fixture -o /dev/null -w "%{http_code}" https://localhost:631/admin/)" = 200'
docker exec "$name" sh -c 'lpinfo -m | grep "HP Color Laser 15x Series"'
docker exec --user lp "$name" sh -c \
    'cupsfilter -e -p /usr/share/cups/model/uld-hp/HP_Color_Laser_15x_Series.ppd -m printer/hp150 /usr/share/cups/data/testprint > /tmp/test.spl && test -s /tmp/test.spl'
# Unreachable fixture URI: queue setup only, no print job or external write.
docker exec "$name" lpadmin -p SmokeHP -E -v ipp://127.0.0.1:9/printers/fixture \
    -P /usr/share/cups/model/uld-hp/HP_Color_Laser_15x_Series.ppd
docker restart "$name" >/dev/null
for attempt in $(seq 1 30); do
    if docker exec "$name" healthcheck.sh >/dev/null 2>&1; then break; fi
    if [ "$attempt" -eq 30 ]; then docker logs "$name"; exit 1; fi
    sleep 1
done
docker exec "$name" lpstat -p SmokeHP
docker rm -f "$name" >/dev/null
start
docker exec "$name" lpstat -p SmokeHP
docker rm -f "$name" >/dev/null
if docker run --rm --entrypoint sh "$image" /usr/local/bin/install-driver.sh armv7; then
    echo "Unsupported architecture unexpectedly accepted" >&2
    exit 1
fi
if docker run --rm --entrypoint sh "$image" -c \
    'mkdir -p /data; echo "{\"admin_password\":\"\"}" > /data/options.json; exec run.sh'; then
    echo "Empty password unexpectedly accepted" >&2
    exit 1
fi
echo "Smoke tests passed"
