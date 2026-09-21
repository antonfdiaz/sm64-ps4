#!/usr/bin/env bash
set -e

DEPS_DIR="$(cd "$(dirname "$0")/.." && pwd)/deps"

python3 - <<'PY'
from pathlib import Path

root = Path("deps")

fix_stub = root / "fix_stub.py"
text = fix_stub.read_text()

replacements = {
    "#!/usr/bin/env python2.7": "#!/usr/bin/env python3",
    "'518D64A635DED8C1E6B039B1C3E55230'.decode('hex')":
        "bytes.fromhex('518D64A635DED8C1E6B039B1C3E55230')",
    "MAGIC = '\\x7FELF'": "MAGIC = b'\\x7FELF'",
    "xrange(": "range(",
    ".split('\\0', 1)[0].rstrip('\\0')":
        ".split(b'\\0', 1)[0].rstrip(b'\\0').decode('ascii')",
    "new_name = new_name.ljust(len(name), '\\0')":
        "new_name = new_name.ljust(len(name), '\\0').encode('ascii')",
}

for old, new in replacements.items():
    text = text.replace(old, new)

fix_stub.write_text(text)

preprocess = root / "lib/libScePigletv2VSH/preprocess_hdr.py"
text = preprocess.read_text()

text = text.replace(
    "#!/usr/bin/env python2.7",
    "#!/usr/bin/env python3"
)

text = text.replace(
    "with open(hdr_file_path, 'rb') as f:",
    "with open(hdr_file_path, 'r', encoding='utf-8') as f:"
)

preprocess.write_text(text)

print("deps patched for Python 3")
PY