# Changelog

## 0.1.1

- Fix HAOS installation builds on Raspberry Pi 5 / aarch64 by using Debian
  trixie-slim directly in the Dockerfile, independent of Supervisor BUILD_FROM.
- Remove deprecated build.yaml and align image labels with current Home Assistant
  app metadata conventions.
- Preserve amd64/aarch64 support and the official HP Color Laser 15x driver flow.

## 0.1.0

- Initial Debian 13 / CUPS 2.4 HAOS add-on for amd64 and aarch64.
- Verified HP ULD 15x driver download, USB access, authenticated CUPS UI.
- Persistent queue configuration and spool; runtime driver and scheduler checks.
