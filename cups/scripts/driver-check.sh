#!/bin/sh
set -eu
filter=/usr/lib/cups/filter/rastertospl
library=/opt/smfp-common/printer/lib/libscmssc.so
test -x "$filter"
test -r "$library"
test -r /usr/share/cups/model/uld-hp/cms/15xsc.cts
test -r /usr/share/cups/model/uld-hp/HP_Color_Laser_15x_Series.ppd
for binary in "$filter" "$library"; do
    output=$(ldd "$binary" 2>&1) || { echo "$output" >&2; exit 1; }
    if printf '%s\n' "$output" | grep -q 'not found'; then
        echo "$output" >&2
        exit 1
    fi
done
# libscmssc is dlopen()ed, so ldd(filter) alone does not check it.
python3 - <<'PY'
import ctypes
ctypes.CDLL("/opt/smfp-common/printer/lib/libscmssc.so")
PY
dpkg-query -W -f='${Version}\n' cups | grep -E '^2\.4\.'
