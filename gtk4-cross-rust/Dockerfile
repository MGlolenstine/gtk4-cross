FROM mglolenstine/gtk4-cross:%GTKTAG%

# Add build.sh
ADD build.sh /usr/bin/build
RUN dos2unix /usr/bin/build
RUN chmod +x /usr/bin/build

# Add package.sh
ADD package.sh /usr/bin/package
RUN dos2unix /usr/bin/package
RUN chmod +x /usr/bin/package

# Add package_with_icons.sh
ADD package_with_icons.sh /usr/bin/package_with_icons
RUN dos2unix /usr/bin/package_with_icons
RUN chmod +x /usr/bin/package_with_icons

# Setup rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN . ~/.cargo/env && \
    rustup target add x86_64-pc-windows-gnu

# Set default linker to the GCC linker
ADD cargo.config ~/.cargo/config

CMD ["/bin/bash"]
