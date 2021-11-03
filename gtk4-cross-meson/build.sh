#!/bin/bash
source ~/.cargo/env
export MINGW_PREFIX=/usr/x86_64-w64-mingw32/sys-root/mingw/

x86_64-meson /tmp/_build -Dwindows=true --prefix=/usr
meson compile -C /tmp/_build

mkdir -p package
cp /tmp/_build/target/x86_64-pc-windows-gnu/release/*.exe package
mkdir -p package/data
cp /tmp/_build/data/resources.gresource package/data
mkdir -p package/share/glib-2.0/schemas
cp /tmp/_build/data/*.gschema.xml package/share/glib-2.0/schemas
glib-compile-schemas package/share/glib-2.0/schemas

