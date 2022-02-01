FROM mglolenstine/gtk4-cross:rust-gtk-4.6

# Add build.sh
ADD build.sh /usr/bin/build
RUN chmod +x /usr/bin/build

# Add package.sh
ADD package.sh /usr/bin/package
RUN chmod +x /usr/bin/package

# Setup rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN . ~/.cargo/env && \
    rustup target add x86_64-pc-windows-gnu

# Set default linker to the GCC linker
ADD cargo.config /home/rust/.cargo/config

CMD ["/bin/bash"]
