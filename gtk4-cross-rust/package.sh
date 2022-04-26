#!/bin/bash
set -euo pipefail
DLLS=$(pds package/*.exe -f)
export DLLS

for DLL in $DLLS; do
    cp "$DLL" package
	# cp "$DLL" package
done

# Copy libgtk and few other dlls into package
# cp /usr/x86_64-w64-mingw32/bin/*.dll package/
# cp /usr/x86_64-w64-mingw32/sys-root/mingw/bin/*.dll package/

# Add gdbus which is recommended on Windows
cp /usr/x86_64-w64-mingw32/sys-root/mingw/bin/gdbus.exe package


mkdir -p package/share/{themes,gtk-4.0,glib-2.0}
#cp -r $GTK_INSTALL_PATH/share/glib-2.0/schemas package/share/glib-2.0/
#cp -r $GTK_INSTALL_PATH/share/icons package/share/icons

find package -iname "*.dll" -or -iname "*.exe" -type f -exec mingw-strip {} +

zip -qr package.zip package/*
rm -rf package
