#!/bin/sh
set -eu
lpstat -h localhost:631 -r | grep -q 'scheduler is running'
