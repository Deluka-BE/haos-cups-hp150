ARG BUILD_FROM=debian:trixie-slim
FROM ${BUILD_FROM}
ARG BUILD_ARCH
ENV DEBIAN_FRONTEND=noninteractive
# Track Debian stable/security package updates on rebuild.
# hadolint ignore=DL3008
RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d \
    && chmod 755 /usr/sbin/policy-rc.d \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       cups cups-client cups-filters cups-ipp-utils ghostscript \
       printer-driver-gutenprint avahi-daemon dbus libstdc++6 \
       libcupsimage2t64 ca-certificates curl python3 tini \
    && rm -rf /var/lib/apt/lists/*
COPY scripts/install-driver.sh /usr/local/bin/install-driver
RUN sh /usr/local/bin/install-driver "${BUILD_ARCH}" && rm /usr/local/bin/install-driver
COPY scripts/ /usr/local/bin/
COPY cupsd.conf /usr/local/share/cups-addon/cupsd.conf
RUN chmod 755 /usr/local/bin/*.sh \
    && mkdir -p /usr/local/share/cups-addon/defaults \
    && cp -a /etc/cups/. /usr/local/share/cups-addon/defaults/ \
    && driver-check.sh
LABEL io.hass.name="CUPS HP Color Laser 150" \
      io.hass.description="Debian CUPS with official HP ULD 15x USB driver" \
      io.hass.version="0.1.0" \
      io.hass.type="addon" \
      io.hass.arch="${BUILD_ARCH}"
EXPOSE 631
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD ["/usr/local/bin/healthcheck.sh"]
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/run.sh"]
