#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
CROSS=${CROSS:-riscv64-unknown-elf}
"${CROSS}-gcc" -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Wl,--no-relax -Wl,-Ttext=0 -Wl,-e,_start -o firmware/smoke.elf firmware/smoke.S
"${CROSS}-objcopy" -O binary firmware/smoke.elf firmware/smoke.bin
python3 - <<'PY'
from pathlib import Path
raw = Path('firmware/smoke.bin').read_bytes()
words = [int.from_bytes(raw[i:i+4].ljust(4, b'\0'), 'little') for i in range(0, len(raw), 4)]
words += [0x00000013] * (1024-len(words))
Path('firmware/smoke.hex').write_text(''.join(f'{x:08x}\n' for x in words[:1024]))
PY
