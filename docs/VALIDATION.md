# Validation

## 0.1.1 install build fix

Performed on 2026-10-10 in an amd64 Alpine workspace.

- `python3 tests/static.py`: passed metadata/YAML, explicit Debian FROM,
  removal of build.yaml/BUILD_FROM, version/changelog/label consistency,
  amd64+aarch64 support, shell syntax, inline Python and archive exclusion.
- ShellCheck 0.11.0 on all add-on shell scripts and tests/smoke.sh: passed.
- Hadolint 2.12.0 on cups/Dockerfile and `git diff --check`: passed.
- Compared metadata with current [Home Assistant app configuration docs](https://developers.home-assistant.io/docs/apps/configuration/):
  explicit FROM, BUILD_ARCH/BUILD_VERSION and io.hass.type="app" labels.
- Docker Hub's Debian trixie-slim index includes linux/amd64 and linux/arm64.
  Downloaded and digest-verified the ARM64 base layer; its os-release identifies
  trixie and usr/bin/apt-get is an AArch64 ELF executable.
- Downloaded the official HP archive and verified its configured SHA256.
  Both rastertospl and libscmssc.so are ELF64 AArch64 for aarch64 and ELF64
  x86-64 for amd64; the required 15x PPD, color profile and EULA are present.
  The HP installation and runtime scripts are unchanged.

No Docker CLI/daemon or ARM binfmt emulation is available in this workspace.
These ARM64 artifact checks do not execute the image or replace a full native
aarch64 build/runtime test. No HAOS Supervisor or physical printer was tested
for this patch. Initial runtime validation below applies to 0.1.0.

## Initial 0.1.0 validation

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
