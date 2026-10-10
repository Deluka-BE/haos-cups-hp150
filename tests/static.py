"""Metadata and shell syntax checks; requires PyYAML."""
import subprocess
from pathlib import Path
import yaml

root = Path(__file__).resolve().parents[1]
config = yaml.safe_load((root / "cups/config.yaml").read_text())
dockerfile = (root / "cups/Dockerfile").read_text()
repository = yaml.safe_load((root / "repository.yaml").read_text())
assert config["version"] == "0.1.1"
assert set(config["arch"]) == {"amd64", "aarch64"}
assert not (root / "cups/build.yaml").exists()
assert dockerfile.splitlines()[0] == "FROM debian:trixie-slim"
assert "BUILD_FROM" not in dockerfile
assert f'ARG BUILD_VERSION={config["version"]}' in dockerfile
assert 'io.hass.version="${BUILD_VERSION}"' in dockerfile
assert 'io.hass.type="app"' in dockerfile
assert 'io.hass.arch="${BUILD_ARCH}"' in dockerfile
assert f'## {config["version"]}' in (root / "cups/CHANGELOG.md").read_text()
assert config["usb"] and config["host_network"]
assert config["schema"]["admin_password"] == "password"
assert repository["url"] == config["url"]
for script in list((root / "cups/scripts").glob("*.sh")) + [root / "tests/smoke.sh"]:
    subprocess.run(["sh", "-n", str(script)], check=True)
run = (root / "cups/scripts/run.sh").read_text().split("<<'PY'\n", 1)[1].split("\nPY", 1)[0]
compile(run, "run.sh inline Python", "exec")
assert not list(root.rglob("*.tar.gz"))
print("Metadata, shell syntax, inline Python and no-archive checks passed")
