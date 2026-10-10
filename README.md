# CUPS HP Color Laser 150 for Home Assistant OS

Public Home Assistant add-on repository for USB printing with the **HP Color
Laser 150a / Color Laser 15x Series**. Initial version: **0.1.0**.

The add-on builds locally on your HAOS host from maintained **Debian 13
(trixie-slim)** with Debian's stable **CUPS 2.4.x**, cups-filters, Ghostscript,
Gutenprint and Avahi. It uses glibc, required by HP's proprietary filter.
Supported architectures: **amd64** and **aarch64**; other architectures and
base-image/architecture mismatches fail at build time. No prebuilt driver
images or release publishing workflows are provided.

## Install and print

1. In Home Assistant, open **Settings → Add-ons → Add-on Store → ⋮ →
   Repositories** and add:
   `https://github.com/Deluka-BE/haos-cups-hp150`.
2. Refresh the store and install **CUPS HP Color Laser 150**. The first build
   requires internet access to Debian and HP and can take several minutes.
3. Under **Configuration**, set a strong, nonempty `admin_password`, save,
   then start the add-on. Enable **Start on boot** and **Watchdog** if desired.
4. Connect the powered-on HP Color Laser 150a directly by USB to the HAOS
   machine. The add-on requests raw USB access with hotplug support.
5. Click **Open Web UI**, or visit `https://<HAOS-IP>:631`. Accept the local
   CUPS self-signed certificate after verifying the address.
6. Select **Administration → Add Printer** and log in as **cupsadmin** with
   your configured password. Select the USB HP printer under **Local Printers**.
   Choose a simple queue name, such as `HP150`, and enable sharing if other
   LAN devices should print.
7. Choose manufacturer **HP**, then **HP Color Laser 15x Series**. Its installed
   PPD is `/usr/share/cups/model/uld-hp/HP_Color_Laser_15x_Series.ppd`.
   Set paper size (A4/Letter) and desired color mode.
8. Open **Printers → HP150 → Maintenance → Print Test Page**. Confirm a real
   page prints in color. For clients, the queue URI is
   `ipp://<HAOS-IP>:631/printers/HP150`; Avahi advertises shared queues.

If USB discovery is empty, check power/cable, add-on logs and HAOS hardware
visibility; unplug/replug USB and refresh Add Printer. Do not select a generic
PCL/PostScript driver for this SPL-C printer. Scanning and HP's network discovery
utilities are outside this add-on's scope.

## Network and persistence

Host networking permits LAN mDNS/Avahi discovery and exposes TCP **631** directly.
The port is fixed; stop any other service using it. CUPS is restricted to local
networks and administration requires authentication over HTTPS. Printing is
available to local clients without administrator credentials. This UI uses a
direct Web UI link rather than Home Assistant ingress; do not forward port 631
to the internet. USB access does not require full privileged mode.

CUPS configuration, queue PPDs and certificates are stored in `/data/cups`,
jobs/spool in `/data/spool`, and cache in `/data/cache`. Restarts, image
replacements and add-on updates retain them; include the add-on in HA backups.
Uninstalling the add-on can remove its data. The initial CUPS configuration is
seeded once so later image updates do not overwrite administrator settings.
The `cupsadmin` password is applied from add-on options on each start; changing
it requires a restart. Completed job documents are not retained.

## HP driver and license

At image build time, download only from HP over HTTPS:
[HP ULD V1.00.39.12_00.15](https://ftp.hp.com/pub/softlib/software13/printers/MFP170/uld-hp_V1.00.39.12_00.15.tar.gz).

SHA256: `cebb9b7b6125e7406634bb9c2a98b01477d1e11d66c7c90474669de9927bc91d`.

Only the model PPD, architecture-specific `rastertospl`, `libscmssc.so`,
`cms/15xsc.cts` and HP's EULA are installed. The upstream installer is not
executed. The filter symlink is in `/usr/lib/cups/filter`; its library retains
HP's expected `/opt/smfp-common/printer/lib` path and the color profile retains
the expected CUPS `model/uld-hp/cms` path. No proprietary files are committed.

HP ULD is **proprietary**, subject to HP's EULA, which is inside the downloaded
archive and installed at `/usr/share/doc/hp-uld/EULA.txt`. Review and accept
HP's terms before installing. HP's EULA restricts distribution; this repository
distributes build scripts, not HP binaries or prebuilt images containing them.

## Development and verification

Build on the corresponding native architecture (or with already-configured
Docker multiarchitecture emulation):

```sh
docker build --platform linux/amd64 --build-arg BUILD_ARCH=amd64 \
  -t haos-cups-hp150:test cups
# For ARM64: --platform linux/arm64 --build-arg BUILD_ARCH=aarch64
sh tests/smoke.sh haos-cups-hp150:test
python3 tests/static.py
docker run --rm -v "$PWD:/src:ro" -w /src koalaman/shellcheck:stable \
  cups/scripts/*.sh tests/smoke.sh
```

The build/startup driver check verifies linked dependencies and explicitly
loads the dynamically opened libscmssc library. Startup validates CUPS
configuration; the container health check queries the running scheduler.
The smoke test uses an isolated Docker network and temporary named data volume,
never a physical printer: it checks startup, HTTPS authentication, advertised
PPD, full test-page-to-SPL filter conversion, queue persistence after restart
and replacement, and clean missing-password/unsupported-architecture failures.

See [validation results](docs/VALIDATION.md) for the actual tests and hardware
limitations of this initial implementation. Debian packages are installed
unversioned from stable/security repositories to receive fixes when rebuilt.
CUPS 2.4.x is the Debian stable line, not necessarily upstream's latest release.
See [Debian CUPS](https://packages.debian.org/trixie/cups) and
[HA add-on configuration](https://developers.home-assistant.io/docs/apps/configuration/).

[Changelog](cups/CHANGELOG.md).
