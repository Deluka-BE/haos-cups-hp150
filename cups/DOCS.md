# Configure and use

1. Set `admin_password` in the add-on Configuration tab before starting.
2. Attach the powered-on HP Color Laser 150a by USB to your HAOS host.
3. Open the Web UI at `https://<HAOS-IP>:631`. Verify the local address and
   accept the self-signed CUPS certificate.
4. Log into Administration → Add Printer as **cupsadmin** with your configured
   password. Select the local USB HP printer.
5. Choose **HP → HP Color Laser 15x Series**, set paper size/color and optionally
   share the queue on your LAN.
6. Under Printers → your queue → Maintenance, choose **Print Test Page**.

TCP 631 is fixed because the add-on uses host networking for Avahi discovery.
Keep it on a trusted LAN. If the port is occupied, stop the other print server.
The add-on uses direct USB access without full privileged mode.

Queue configuration, PPDs, certificates, cache and spool live under `/data`.
Include this add-on in backups. Restart after changing the administrator
password; updates preserve existing CUPS configuration.

If no USB device appears, check the cable, power and HAOS hardware visibility,
reconnect it and refresh the CUPS page. The add-on logs report configuration or
driver loader failures. Other architectures than amd64/aarch64 are unsupported.

HP's proprietary ULD driver is downloaded and checksum-verified at build time.
Review HP's EULA inside the archive before installation; its installed copy is
`/usr/share/doc/hp-uld/EULA.txt`. No driver binaries are in the repository.

For build instructions, detailed runtime paths, license notes and validation,
see the [repository README](https://github.com/Deluka-BE/haos-cups-hp150#readme).
