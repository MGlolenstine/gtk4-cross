FROM gtk4-cross-base

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
