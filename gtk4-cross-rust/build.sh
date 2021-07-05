#!/bin/bash
source ~/.cargo/env
cargo build --target=x86_64-pc-windows-gnu --release

mkdir -p package
cp target/x86_64-pc-windows-gnu/release/*.exe package