#!/usr/bin/env bash
# Fetch third-party tool sources only when needed; keep the core repo lean.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/tools"

fetch_pin() {
  local name="$1" url="$2" commit="$3"
  local dest="$ROOT/tools/$name"
  if [[ ! -d "$dest/.git" ]]; then
    rm -rf "$dest"
    git clone "$url" "$dest"
  fi
  git -C "$dest" fetch --quiet origin "$commit" || true
  git -C "$dest" checkout --quiet --detach "$commit"
}

case "${1:-all}" in
  mcy) fetch_pin mcy https://github.com/YosysHQ/mcy.git 5a2cad0cbefceb7f23051c08348bd23128fd1046 ;;
  spike) fetch_pin riscv-isa-sim https://github.com/riscv-software-src/riscv-isa-sim.git 982f078e65ab52d5d9a91248c2178f5399df7783 ; git -C "$ROOT/tools/riscv-isa-sim" submodule update --init --recursive ;;
  all)
    fetch_pin mcy https://github.com/YosysHQ/mcy.git 5a2cad0cbefceb7f23051c08348bd23128fd1046
    fetch_pin riscv-isa-sim https://github.com/riscv-software-src/riscv-isa-sim.git 982f078e65ab52d5d9a91248c2178f5399df7783
    git -C "$ROOT/tools/riscv-isa-sim" submodule update --init --recursive
    ;;
  *) echo "usage: $0 [mcy|spike|all]" >&2; exit 2 ;;
esac
