#!/bin/bash
set -euo pipefail

# Minimum packaging script for any Windows application.
#
# Before calling this, you should create some output
# directory and install your application there. (You can control the name with the first CLI argument, the default
# is ./package). Note that all binaries must be in the top level and not in /bin; move them out if necessary.

OUT=${1:-package}
mkdir -p $OUT

# Add gdbus (https://discourse.gnome.org/t/gtk-warning-about-gdbus-exe-not-being-found-on-windows-msys2/2893/2)
cp $MINGW_PREFIX/bin/gdbus.exe $OUT
# Add gspawn binaries for launching external processes (https://gitlab.gnome.org/GNOME/glib/-/issues/2843#note_1625472)
cp $MINGW_PREFIX/bin/gspawn-win64-helper-console.exe $MINGW_PREFIX/bin/gspawn-win64-helper.exe $OUT

# Handle the glib schema compilation as well
glib-compile-schemas $MINGW_PREFIX/share/glib-2.0/schemas/
mkdir -p $OUT/share/glib-2.0/schemas/
cp -T $MINGW_PREFIX/share/glib-2.0/schemas/gschemas.compiled $OUT/share/glib-2.0/schemas/gschemas.compiled

# HiColor icon theme (only the index file required at minimum)
mkdir -p $OUT/share/icons/hicolor
cp -T /usr/share/icons/hicolor/index.theme $OUT/share/icons/hicolor/index.theme

# Pixbuf stuff, in order to get SVGs (scalable icons) to load
mkdir -p $OUT/lib/gdk-pixbuf-2.0
cp -rT $MINGW_PREFIX/lib/gdk-pixbuf-2.0 $OUT/lib/gdk-pixbuf-2.0

# Copy all (transitive) dependencies into root, strip them
cp -t $OUT $(pds -vv -f $OUT/*.exe $MINGW_PREFIX/lib/gdk-pixbuf-2.0/2.10.0/loaders/*)
find $OUT -iname "*.dll" -or -iname "*.exe" -type f -exec mingw-strip {} +
