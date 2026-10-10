#!/bin/sh
set -eu
case "${1:-}" in
    amd64) hp_arch=x86_64; deb_arch=amd64 ;;
    aarch64) hp_arch=aarch64; deb_arch=arm64 ;;
    *) echo "Unsupported BUILD_ARCH: expected amd64 or aarch64" >&2; exit 1 ;;
esac
[ "$(dpkg --print-architecture)" = "$deb_arch" ] || {
    echo "BUILD_ARCH does not match Debian image architecture" >&2; exit 1;
}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
curl --fail --location --proto '=https' --proto-redir '=https' \
    --connect-timeout 30 --max-time 300 \
    https://ftp.hp.com/pub/softlib/software13/printers/MFP170/uld-hp_V1.00.39.12_00.15.tar.gz \
    -o "$tmp/uld.tar.gz"
echo "cebb9b7b6125e7406634bb9c2a98b01477d1e11d66c7c90474669de9927bc91d  $tmp/uld.tar.gz" | sha256sum -c -
tar -xzf "$tmp/uld.tar.gz" -C "$tmp" \
    "uld/$hp_arch/rastertospl" "uld/$hp_arch/libscmssc.so" \
    uld/noarch/share/ppd/HP_Color_Laser_15x_Series.ppd \
    uld/noarch/share/ppd/cms/15xsc.cts \
    uld/noarch/license/eula.txt
install -Dm755 "$tmp/uld/$hp_arch/rastertospl" /opt/smfp-common/printer/bin/rastertospl
install -Dm644 "$tmp/uld/$hp_arch/libscmssc.so" /opt/smfp-common/printer/lib/libscmssc.so
ln -s /opt/smfp-common/printer/bin/rastertospl /usr/lib/cups/filter/rastertospl
install -Dm644 "$tmp/uld/noarch/share/ppd/HP_Color_Laser_15x_Series.ppd" \
    /usr/share/cups/model/uld-hp/HP_Color_Laser_15x_Series.ppd
install -Dm644 "$tmp/uld/noarch/share/ppd/cms/15xsc.cts" /usr/share/cups/model/uld-hp/cms/15xsc.cts
install -Dm644 "$tmp/uld/noarch/license/eula.txt" /usr/share/doc/hp-uld/EULA.txt
