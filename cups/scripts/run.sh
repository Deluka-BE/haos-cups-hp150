#!/bin/sh
set -eu
umask 027
# Do not log the password or put it in a process argument.
python3 - <<'PY'
import json
import subprocess
from pathlib import Path
options = json.loads(Path("/data/options.json").read_text())
password = options.get("admin_password", "")
if not password or "\n" in password or "\r" in password:
    raise SystemExit("Set a nonempty, single-line admin_password in add-on configuration.")
if subprocess.run(["id", "cupsadmin"], stdout=subprocess.DEVNULL,
                  stderr=subprocess.DEVNULL).returncode:
    subprocess.run(["useradd", "--no-create-home", "--groups", "lpadmin", "--shell",
                "/usr/sbin/nologin", "cupsadmin"], check=True)
subprocess.run(["chpasswd"], input=f"cupsadmin:{password}\n", text=True, check=True)
PY
mkdir -p /data/cups /data/spool /data/cache /run/cups /run/dbus
if [ ! -f /data/cups/.initialized ]; then
    cp -an /usr/local/share/cups-addon/defaults/. /data/cups/
    cp /usr/local/share/cups-addon/cupsd.conf /data/cups/cupsd.conf
    touch /data/cups/.initialized
fi
# Keep queue PPDs, printer definitions, certificates and job state across updates.
rm -rf /etc/cups /var/spool/cups /var/cache/cups
ln -s /data/cups /etc/cups
ln -s /data/spool /var/spool/cups
ln -s /data/cache /var/cache/cups
chown root:lp /data/cups
chmod 755 /data/cups
chown root:lp /data/spool
chmod 710 /data/spool
mkdir -p /data/spool/tmp
chown lp:lp /data/spool/tmp /data/cache
chmod 1770 /data/spool/tmp
chmod 770 /data/cache
driver-check.sh
cupsd -t
dbus-daemon --system --fork --nopidfile
avahi-daemon --daemonize --no-drop-root
exec cupsd -f
