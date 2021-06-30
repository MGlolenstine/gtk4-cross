FROM fedora:latest
WORKDIR /root
RUN dnf install -y git cmake gcc-c++ boost-devel
RUN git clone https://github.com/gsauthof/pe-util
WORKDIR pe-util
RUN git submodule update --init
RUN mkdir build
WORKDIR build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release
RUN make

FROM fedora:rawhide
COPY --from=0 /root/pe-util/build/peldd /usr/bin/peldd
RUN dnf install git mingw64-binutils mingw64-gcc meson mingw64-pango mingw64-gdk-pixbuf mingw64-libepoxy mingw64-winpthreads-static wine cmake glib2-devel gcc zip boost boost-system -y && dnf clean all -y

# Clone the gtk4 repository (Move after the mingw setup for efficiency later)
WORKDIR /tmp
RUN git clone https://gitlab.gnome.org/GNOME/gtk.git

# Make the meson use mingw
ADD x86_64-meson /usr/bin
RUN chmod +x /usr/bin/x86_64-meson

# Add mingw-env
ADD mingw-env /usr/bin
RUN chmod +x /usr/bin/mingw-env

# Add package.sh
ADD package.sh /usr/bin
RUN chmod +x /usr/bin/package.sh

# Update with the new toolchain file
ADD toolchain-mingw64.meson /usr/share/mingw

# Hacks for GTK4 to compile
#ENV PKG_CONFIG_PATH /usr/x86_64-w64-mingw32/lib/pkgconfig
RUN cp /usr/x86_64-w64-mingw32/sys-root/mingw/include/windows.h /usr/x86_64-w64-mingw32/sys-root/mingw/include/Windows.h

# Enable Iphlpapi (on windows, they're case-insensitive, on linux they're not.)
RUN cp /usr/x86_64-w64-mingw32/sys-root/mingw/lib/libiphlpapi.a /usr/x86_64-w64-mingw32/sys-root/mingw/lib/libIphlpapi.a

# Build and install GTK4
WORKDIR /tmp/gtk
RUN x86_64-meson build --wrap-mode=default
WORKDIR build
RUN meson configure -Db_lto=false -Dc_link_args="['-lssp']"
RUN ninja all && ninja install

# Setup rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN . ~/.cargo/env && \
    rustup target add x86_64-pc-windows-gnu

# Set default linker to the GCC linker
ADD cargo.config /home/rust/.cargo/config

# Add compiler paths
ENV PKG_CONFIG_ALLOW_CROSS=1
ENV PKG_CONFIG_PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/lib/pkgconfig/:/usr/x86_64-w64-mingw32/lib/pkgconfig/
ENV GTK_INSTALL_PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/

# Return to the current working directory
WORKDIR /mnt

CMD ["/bin/bash"]