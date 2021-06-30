#!/bin/bash

source ~/.cargo/env
cargo build --target=x86_64-pc-windows-gnu --release

mkdir -p package
cp target/x86_64-pc-windows-gnu/release/*.exe package

export DLLS=`peldd package/*.exe -t --ignore-errors`
for DLL in $DLLS
           #do cp /usr/x86_64-w64-mingw32/bin/"$DLL" package
           do cp "$DLL" package
done

# Copy libgtk and few other dlls into package
cp /usr/x86_64-w64-mingw32/bin/*.dll package/
cp /usr/x86_64-w64-mingw32/sys-root/mingw/bin/*.dll package/

# Add gdbus which is recommended on Windows
cp /usr/x86_64-w64-mingw32/sys-root/mingw/bin/gdbus.exe package


mkdir -p package/share/{themes,gtk-4.0,glib-2.0}
#cp -r $GTK_INSTALL_PATH/share/glib-2.0/schemas package/share/glib-2.0/
#cp -r $GTK_INSTALL_PATH/share/icons package/share/icons

if [ -z "$WIN_THEME" ]
then
	  cat <<-EOF > package/share/gtk-4.0/settings.ini
	[Settings]
	gtk-font-name = Segoe UI 10
	gtk-xft-rgba = rgb
	gtk-xft-antialias = 1
EOF
else
	  cp -r /home/rust/Windows10 package/share/themes

	  cat <<-EOF > package/share/gtk-4.0/settings.ini
	[Settings]
	gtk-theme-name = Windows10
	gtk-font-name = Segoe UI 10
	gtk-xft-rgba = rgb
	gtk-xft-antialias = 1
	EOF
fi

find package -maxdepth 1 -type f -exec mingw-strip {} +

zip -qr package.zip package/*
rm -rf package
