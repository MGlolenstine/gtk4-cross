# Rust GTK4 GUI smoke application

A small libadwaita window with a name entry, greeting button, and click counter.
The title and version label come from the loaded GTK/libadwaita libraries, not
build-time constants. It uses the GTK 4.6/libadwaita 1.1 API subset so the same
source can run against both the oldest and newest configured stable pairs.

From this directory, run the repository's Rust image with this directory mounted
at `/mnt`, then run `build` and `package` inside it. `package/` contains the
Windows executable, DLLs, and data files. Run the executable from that directory
on Windows, or with Wine and an available graphical display.

For example, after building the corresponding images:

```sh
docker run --rm -v "$PWD:/mnt" mglolenstine/gtk4-cross:rust-gtk-4.6 bash -c 'build && package'
```

Check that the runtime versions match the selected image. Click the button
without a name to see `Hello, world! Clicks: 1`, then enter a name and click
again. The displayed greeting and counter should update. Close and relaunch
the application to check that the counter resets.

## Verification scope

The same source and Cargo lockfile were cross-compiled and packaged against
GTK 4.6.3/libadwaita 1.1.1 and GTK 4.24.1/libadwaita 1.10.0 on Fedora 45
(prerelease) in October 2026. Both Windows executables were exercised in a
graphical desktop using Wine 11.20 (Staging): empty-name greeting, typed names
with surrounding whitespace, click counts, and close/relaunch with reset state.
The runtime tests used the packaged DLLs, with the build sysroot hidden.

The Rust crates were already the latest published stable versions when checked
on October 29, 2026: `gtk4 0.11.5` and `libadwaita 0.9.2`. Cargo found no
compatible dependency updates. The `v4_6`/`v1_1` features specify the minimum
native-library API level, not older Rust crate versions. A second newest-pair
build and package passed with the full API feature level enabled:

```sh
cargo build --target x86_64-pc-windows-gnu --release --locked --features gtk/v4_24,adw/v1_10,adw/gtk_v4_24
```

That packaged executable also passed empty-name and typed-name greeting checks
under Wine. The demo still uses baseline widgets; enabling newer APIs does not
mean every newly available API was exercised.

These Wine runs required `GSK_RENDERER=cairo`, `PANGOCAIRO_BACKEND=fc`, a local
fontconfig configuration using installed Linux fonts, and a US keyboard-layout
DLL/registry entry in each Wine prefix. The keyboard DLL was compiled from
ReactOS sources and was not added to the application bundles. Without this
setup, the oldest version's default GPU path crashed, text was damaged on both
versions, and keyboard input did not work. The Rust application itself does not
force these compatibility settings.

This verifies the packaged GUI under that Wine setup, not native Windows,
hardware-accelerated rendering, or the default font path. Whether the rendering
issues also occur on native Windows remains unverified.

## Windows keyboard DLL and Wine window borders

Windows supplies its own US keyboard-layout DLL (`kbdus.dll`), not the ReactOS
implementation. Do not bundle the ReactOS replacement or install it on Windows;
it is only a workaround for these Wine prefixes. Microsoft documents the
[standard keyboard layouts](https://learn.microsoft.com/en-us/globalization/windows-keyboard-layouts)
and [keyboard layout DLLs](https://learn.microsoft.com/en-us/samples/microsoft/windows-driver-samples/keyboard-layout-samples/).

The black surround in the floating-window Wine screenshots is the intended
transparent shadow/resize area. Both runs logged `DwmEnableBlurBehindWindow`
failing with `0x80004001` (`E_NOTIMPL`); Wine 11.20's implementation is a stub.
Disabling CSS shadows only shrank it: GTK still reserves an invisible resize
margin. Maximizing the newest demo removed that area and the black surround.
No application styling changes or CSS overrides were retained.
