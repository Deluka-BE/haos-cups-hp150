"""Metadata and shell syntax checks; requires PyYAML."""
import subprocess
from pathlib import Path
import yaml

root = Path(__file__).resolve().parents[1]
config = yaml.safe_load((root / "cups/config.yaml").read_text())
build = yaml.safe_load((root / "cups/build.yaml").read_text())
repository = yaml.safe_load((root / "repository.yaml").read_text())
assert config["version"] == "0.1.0"
assert set(config["arch"]) == {"amd64", "aarch64"}
assert set(build["build_from"]) == set(config["arch"])
assert all(value == "debian:trixie-slim" for value in build["build_from"].values())
assert config["usb"] and config["host_network"]
assert config["schema"]["admin_password"] == "password"
assert repository["url"] == config["url"]
for script in list((root / "cups/scripts").glob("*.sh")) + [root / "tests/smoke.sh"]:
    subprocess.run(["sh", "-n", str(script)], check=True)
run = (root / "cups/scripts/run.sh").read_text().split("<<'PY'\n", 1)[1].split("\nPY", 1)[0]
compile(run, "run.sh inline Python", "exec")
assert not list(root.rglob("*.tar.gz"))
print("Metadata, shell syntax, inline Python and no-archive checks passed")
