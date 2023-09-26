#!/bin/bash

rustup toolchain install nightly
rustup target add aarch64-apple-ios-sim --toolchain nightly
rustup component add rust-src --toolchain nightly-aarch64-apple-darwin
rustup component add rust-src --toolchain nightly-aarch64-apple-darwin
rustup target add aarch64-apple-ios x86_64-apple-ios

rustup target list --installed | grep ios
