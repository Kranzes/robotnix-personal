#!/bin/sh
export TMPDIR="/home/1TB-HDD/Android/tmp"
nix build -L --store "/home/1TB-HDD/Android/store" --option extra-sandbox-paths "/keys=/home/1TB-HDD/Android/robotnix/keys" -j$(nproc) --cores $(nproc)

