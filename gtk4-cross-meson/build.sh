#!/bin/bash
source ~/.cargo/env
export MINGW_PREFIX=/usr/x86_64-w64-mingw32/sys-root/mingw/

x86_64-meson _build -Dwindows=true --prefix=/usr
meson compile -C _build

mkdir -p package
cp _build/target/x86_64-pc-windows-gnu/release/*.exe package
