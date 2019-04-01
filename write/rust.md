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
explicitly.

## Accessing Argdata

The code below shows how our "Hello, world" application can be extended
to actually work. The `argdata` crate provides access to the arguments
passed to the process. The `cloudabi` create contains bindings against
the CloudABI system call interface. We use it to implement an object
with trait `std::io::Write`.

In the long run, we want to work towards simplifying this code
dramatically. There should be no need to implement the `Console` object
yourself.

```
$ cat Cargo.toml
[package]
name = "hello_world"
version = "0.1.0"
authors = ["Your Name <you@example.com>"]

[dependencies]
argdata = "*"
cloudabi = "*"
$ cat src/main.rs
#![feature(set_stdio)]

extern crate argdata;
extern crate cloudabi;

use argdata::Argdata;
use argdata::ArgdataExt;

pub struct Console(cloudabi::fd);

impl std::io::Write for Console {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        unsafe {
            let iovs = [
                cloudabi::ciovec {
                    buf: (buf.as_ptr() as *const _ as *const (), buf.len()),
                },
            ];
            let mut nwritten = std::mem::uninitialized();
            cloudabi::fd_write(self.0, &iovs, &mut nwritten);
        }
        Ok(buf.len())
    }

    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}

fn main() {
    let ad = argdata::env::argdata();
    let mut it = ad.read_map().expect("argdata should be a map");
    while let Some(Ok((key, val))) = it.next() {
        match key.read_str().expect("keys should be strings") {
            "console" => {
                let fd = val.read_fd().expect("console should be a file descriptor");
                std::io::set_print(Some(Box::new(Console(cloudabi::fd(fd.0 as u32)))));
                std::io::set_panic(Some(Box::new(Console(cloudabi::fd(fd.0 as u32)))));
            }
            _ => {}
        }
    }

    println!("Hello, world!");
}
$ cargo build --target=x86_64-unknown-cloudabi
$ cloudabi-run target/x86_64-unknown-cloudabi/debug/hello_world << EOF
%TAG ! tag:nuxi.nl,2015:cloudabi/
---
console: !fd stdout
EOF
Hello, world!
```
