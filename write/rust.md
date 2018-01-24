---
layout: page
title: Writing CloudABI applications in Rust
permalink: /write/rust/
---

## Installing a toolchain

Installing a toolchain for Rust is very easy, as support for CloudABI
has been upstreamed into the Rust codebase. Automated builds are
performed by the Rust developers. As there hasn't been a stable release
of Rust to include CloudABI support yet, you must for now make use of
Rust's nightly track.

A commonly used method for installing the Rust compiler is to use
[rustup](https://www.rustup.rs/). If rustup is not available through
your system's package manager, it can be installed in your home
directory by running the official installation shell script:

```sh
curl https://sh.rustup.rs -sSf | sh
```

Once rustup is installed, the following commands can be used download a
copy of the Rust standard libraries for CloudABI:

```sh
rustup toolchain install nightly
rustup default nightly
rustup target add x86_64-unknown-cloudabi
```

Rust depends on [cloudlibc](https://github.com/NuxiNL/cloudlibc) for
memory allocation and threading. It also makes use of LLVM's libunwind
to provide backtraces upon `panic!()`. You must therefore
[install a toolchain for C and C++](../c/) to be able to link actual
binaries.

## Building a simple application

Assuming that both a C++ and Rust toolchain are installed, it is
possible to build Rust applications for CloudABI by making use of
Cargo's `--target` flag:

```
$ cat Cargo.toml
[package]
name = "hello_world"
version = "0.1.0"
authors = ["Your Name <you@example.com>"]
$ cat src/main.rs
fn main() {
    println!("Hello, world!");
}
$ cargo build --target=x86_64-unknown-cloudabi
```

The resulting executable can be started with `cloudabi-run` as follows:

```sh
cloudabi-run target/x86_64-unknown-cloudabi/debug/hello_world < /dev/null
```

This will, however, not generate any output, for the reason that an
output sink (`stdout`) needs to be provided in the YAML configuration
explicitly. For example:

```sh
cloudabi-run target/x86_64-unknown-cloudabi/debug/hello_world << EOF
%TAG ! tag:nuxi.nl,2015:cloudabi/
---
console: !fd stdout
EOF
```

Unfortunately, fields in the YAML specification cannot be accessed from
within Rust code yet, as Rust bindings for
[Argdata](https://github.com/NuxiNL/argdata) are still being
implemented. This documentation will be updated as soon as these
bindings become available.
