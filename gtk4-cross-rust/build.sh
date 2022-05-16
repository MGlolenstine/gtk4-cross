#!/bin/bash
set -euo pipefail
# shellcheck source=/dev/null
source "$HOME/.cargo/env"
cargo build --target=x86_64-pc-windows-gnu --release --locked

mkdir -p package
cp target/x86_64-pc-windows-gnu/release/*.exe package/

# Handle the glib schema compilation as well
glib-compile-schemas /usr/x86_64-w64-mingw32/sys-root/mingw/share/glib-2.0/schemas/
mkdir -p package/share/glib-2.0/schemas/
cp /usr/x86_64-w64-mingw32/sys-root/mingw/share/glib-2.0/schemas/gschemas.compiled package/share/glib-2.0/schemas/
