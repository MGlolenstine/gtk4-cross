FROM fedora:36
WORKDIR /root
RUN dnf install -y git cmake gcc-c++ boost-devel
RUN git clone https://github.com/gsauthof/pe-util
WORKDIR /root/pe-util
RUN git submodule update --init
RUN mkdir build
WORKDIR /root/pe-util/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release
RUN make

FROM fedora:36
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
# RUN . ~/.cargo/env 
# Set the rust linker to gcc
# RUN echo "[target.x86_64-pc-windows-gnu]\nlinker = \"x86_64-w64-mingw32-gcc\"\nar = \"x86_64-w64-mingw32-gcc-ar\"" > /home/rust/.cargo/config
RUN dnf install -y gcc
RUN . ~/.cargo/env && cargo install --git https://github.com/MGlolenstine/peldd_dependency_scanner.git

FROM fedora:36
COPY --from=0 /root/pe-util/build/peldd /usr/bin/peldd
COPY --from=1 /root/.cargo/bin/peldd_dependency_scanner /usr/bin/pds
RUN dnf install git mingw64-binutils mingw64-gcc meson mingw64-pango mingw64-gdk-pixbuf mingw64-libepoxy mingw64-winpthreads-static glib2-devel gobject-introspection-devel mingw64-gstreamer1-plugins-bad-free vala wine cmake gcc zip boost boost-system dos2unix sassc -y && dnf clean all -y

# Clone the gtk4 repository (Move after the mingw setup for efficiency later)
WORKDIR /tmp
RUN git clone --depth 1 --branch %GTKTAG% https://gitlab.gnome.org/GNOME/gtk.git

# Clone the libadwaita repository (Move after the mingw setup for efficiency later)
WORKDIR /tmp
RUN git clone --depth 1 --branch %ADWTAG% https://gitlab.gnome.org/GNOME/libadwaita.git

# Make the meson use mingw
ADD x86_64-meson /usr/bin
RUN dos2unix /usr/bin/x86_64-meson
RUN chmod +x /usr/bin/x86_64-meson

# Add mingw-env
ADD mingw-env /usr/bin
RUN dos2unix /usr/bin/mingw-env
RUN chmod +x /usr/bin/mingw-env

# Update with the new toolchain file
ADD toolchain-mingw64.meson /usr/share/mingw
RUN dos2unix /usr/share/mingw/toolchain-mingw64.meson

# Hacks for GTK4 to compile
#ENV PKG_CONFIG_PATH /usr/x86_64-w64-mingw32/lib/pkgconfig
RUN cp /usr/x86_64-w64-mingw32/sys-root/mingw/include/windows.h /usr/x86_64-w64-mingw32/sys-root/mingw/include/Windows.h

RUN if [[ -e /tmp/gtk/gdk/loaders/gdkjpeg.c ]] ; then echo -e "#include <stdlib.h>\n$(cat /tmp/gtk/gdk/loaders/gdkjpeg.c)" > /tmp/gtk/gdk/loaders/gdkjpeg.c ; fi

# Enable Iphlpapi (on windows, they're case-insensitive, on linux they're not.)
RUN cp /usr/x86_64-w64-mingw32/sys-root/mingw/lib/libiphlpapi.a /usr/x86_64-w64-mingw32/sys-root/mingw/lib/libIphlpapi.a

# Add compiler paths
ENV PKG_CONFIG_ALLOW_CROSS=1
ENV PKG_CONFIG_PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/lib/pkgconfig/:/usr/x86_64-w64-mingw32/lib/pkgconfig/
ENV GTK_INSTALL_PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/

# Build and install GTK4
WORKDIR /tmp/gtk
RUN x86_64-meson build -Dintrospection=disabled --wrap-mode=default
WORKDIR /tmp/gtk/build
RUN meson configure -Db_lto=false -Dc_link_args="['-lssp']" -Dc_args=-DG_ENABLE_DEBUG
RUN ninja all && ninja install

# Build and install libadwaita
WORKDIR /tmp/libadwaita
RUN x86_64-meson -Dintrospection=disabled -Dexamples=false -Dvapi=false build --wrap-mode=default
WORKDIR /tmp/libadwaita/build
RUN meson configure -Db_lto=false -Dc_link_args="['-lssp']"
RUN ninja all && ninja install

# Return to the current working directory
WORKDIR /mnt

CMD ["/bin/bash"]
