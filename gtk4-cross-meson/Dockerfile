FROM mglolenstine/gtk4-base

RUN dnf install git mingw64-binutils mingw64-gcc meson mingw64-pango mingw64-gdk-pixbuf mingw64-libepoxy mingw64-sqlite mingw64-winpthreads-static glib2-devel gobject-introspection-devel mingw64-gstreamer1-plugins-bad-free vala wine cmake gcc zip boost sqlite sqlite-devel boost-system -y && dnf update -y && dnf clean all -y

# Add meson executable
ADD x86_64-meson /usr/bin
RUN chmod +x /usr/bin/x86_64-meson

# Add mingw-env executable
ADD mingw-env /usr/bin
RUN chmod +x /usr/bin/mingw-env

# Update with the new toolchain file
ADD toolchain-mingw64.meson /usr/share/mingw

# Add build.sh
ADD build.sh /usr/bin
RUN chmod +x /usr/bin/build.sh

# Add package.sh
ADD package.sh /usr/bin
RUN chmod +x /usr/bin/package.sh

# Setup rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN . ~/.cargo/env && \
    rustup target add x86_64-pc-windows-gnu

# Set default linker to the GCC linker
ADD cargo.config /home/rust/.cargo/config

CMD ["/bin/bash"]
