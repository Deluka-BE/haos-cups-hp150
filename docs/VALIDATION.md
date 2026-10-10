# Initial 0.1.0 validation

Performed on 2026-10-10 on a Linux amd64 Docker host.

## Passed

- Public GitHub repository returns HTTP 200 without authentication; repository
  cloned with its dedicated SSH deploy key.
- Official HP HTTPS archive SHA256 matches the configured checksum.
- amd64 Docker image builds from Debian trixie-slim with Debian
  CUPS **2.4.10-3+deb13u2**; no legacy repositories or package downgrades.
- Both HP driver architectures exist; ELF headers identify x86-64 and AArch64.
  ARM64 filter dependencies are the glibc/CUPS libraries supplied by Debian.
- Metadata/YAML invariants, shell syntax, inline Python syntax, archive exclusion,
  ShellCheck and Hadolint. Hadolint's package pinning warning is intentionally
  suppressed at the apt layer to track maintained stable/security packages.
- Build/runtime driver checks: executable filter, profile/PPD existence,
  ldd of filter and library, explicit ctypes load of dynamically opened library,
  Debian CUPS 2.4 version assertion.
- Isolated Docker smoke test: cupsd configuration/startup and health query,
  HTTPS admin rejects unauthenticated access and accepts configured credentials,
  PPD appears in lpinfo, complete CUPS test-page conversion to nonempty SPL
  through banner/PDF/Ghostscript/rastertospl, running as CUPS's unprivileged lp user.
- Queue persists across restart and replacement using the same temporary data
  volume. Test queue uses unreachable loopback IPP; no printer/service writes.
- Unsupported architecture and empty administrator password fail clearly.
- An additional disposable strace container confirms rastertospl successfully
  opens /opt/smfp-common/printer/lib/libscmssc.so and the actual 15xsc.cts
  in /usr/share/cups/model/uld-hp/cms during test-page conversion.
- git diff --check.

## Hardware/runtime limitations

The host lacks ARM64 binfmt/emulation: running an ARM64 Debian container returns
exec format error. Thus ARM64 archive/base availability and ELF dependencies are
verified statically, but an aarch64 image build/runtime test remains required on
a native ARM64 host (or separately configured emulation). The image's own
dependency checks fail the build if it cannot load the ARM64 driver.

No HAOS Supervisor or physical HP Color Laser 150a is attached. Before treating
this as hardware-validated, install on amd64 and aarch64 HAOS, check Supervisor
metadata/build, USB hotplug permissions and enumeration, print actual color and
grayscale A4/Letter pages, check LAN Avahi discovery from a client, then restart,
update and restore a backup to confirm queue retention. Do not assume filter
conversion proves USB transport or physical print quality.

No prebuilt image, release tag or publication workflow was created. HP's EULA
restricts redistribution, so builds download from HP on the user's host.
