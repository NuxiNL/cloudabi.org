---
layout: page
title: Writing CloudABI applications in C and C++
permalink: /write/c/
---

## Installing a toolchain

Installing a C/C++ toolchain for CloudABI is very easy, as support for
CloudABI is part of [Clang](https://clang.llvm.org/) ≥3.7 and
[LLD](https://lld.llvm.org/) ≥4.0. Clang automatically detects that it
should act as a cross compiler when it's invoked with a
[GNU target triplet](http://wiki.osdev.org/Target_Triplet) in its name,
meaning it is sufficient to create a *symlink farm*, pointing to LLVM
utilities. This may be set up as follows on Debian-based systems:

```sh
apt-get install clang-5.0 lld-5.0 llvm-5.0
prefix=/usr
llvmroot=/usr/lib/llvm-5.0
for target in aarch64-unknown-cloudabi armv6-unknown-cloudabi-eabihf \
              armv7-unknown-cloudabi-eabihf i686-unknown-cloudabi \
              x86_64-unknown-cloudabi; do
  for tool in ar nm objdump ranlib size; do
    ln -s ${llvmroot}/bin/llvm-${tool} ${prefix}/bin/${target}-${tool}
  done
  ln -s ${llvmroot}/bin/clang ${prefix}/bin/${target}-cc
  ln -s ${llvmroot}/bin/clang ${prefix}/bin/${target}-c++
  ln -s ${llvmroot}/bin/lld ${prefix}/bin/${target}-ld
  ln -s ${prefix}/${target} ${llvmroot}/${target}
done
```

Do note that some systems provide packages for this, meaning you don't
have to create these symbolic links yourself. We're still interested in
having packages upstreamed for systems not listed below...

- **Arch Linux**
  ```
yaourt -S cloudabi-toolchain
```
- **FreeBSD**
  ```
pkg install cloudabi-toolchain
```
- **macOS**
  ```
brew tap nuxinl/cloudabi
brew install cloudabi-toolchain
```

## Installing standard libraries

Clang does not ship with any cross compiled libraries for CloudABI,
meaning that you won't be able to build applications for CloudABI yet:

```
$ cat example.c
#include <program.h>
#include <stdlib.h>

void program_main(const argdata_t *ad) {
  exit(123);
}
$ x86_64-unknown-cloudabi-cc -o example example.c
example.c:1:10: fatal error: 'program.h' file not found
#include <program.h>
         ^~~~~~~~~~~
1 error generated.
```

Cross compiled copies of C/C++ libraries are instead provided by
[CloudABI Ports](https://github.com/NuxiNL/cloudabi-ports). After
[configuring your package manager to access CloudABI Ports](../../ports/),
you can install a basic C/C++ runtime as follows:

- **Arch Linux**
  ```
pacman -S x86_64-unknown-cloudabi-cxx-runtime
```
- **Debian**
  ```
apt-get install x86-64-unknown-cloudabi-cxx-runtime
```
- **Fedora**
  ```
dnf install -y x86_64-unknown-cloudabi-cxx-runtime
```
- **FreeBSD**
  ```
pkg install x86_64-unknown-cloudabi-cxx-runtime
```
- **macOS**
  ```
brew install x86_64-unknown-cloudabi-cxx-runtime
```
- **NetBSD**
  ```
pkg_add https://nuxi.nl/distfiles/cloudabi-ports/netbsd/x86_64-unknown-cloudabi-cxx-runtime-\*
```
- **openSUSE**
  ```
zypper install -y x86_64-unknown-cloudabi-cxx-runtime
```

In addition to the basic C/C++ runtime, there are many other libraries
that are readily available. Don't forget to
[browse through the list of existing packages](https://github.com/NuxiNL/cloudabi-ports/tree/master/packages)
if you want to build an application that depends other libraries. Have
you ported a library to CloudABI that hasn't been packaged yet? Be sure
to package it and send us a pull request!

## Tips & Tricks

It is important to keep in mind that certain features provided by most
conventional operating systems are incompatible with CloudABI's security
model. For example, POSIX `open()` is insecure, whereas
[`openat()` without `AT_FDCWD`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/open.html)
is. The latter allows for exposing only parts of the file system
namespace to a CloudABI process. Networking related system calls like
`bind()` and `connect()` are also insecure, as they cannot be
constrained without special kernel frameworks (i.e., firewalls). Socket
pairs and [file descriptor passing (`SCM_RIGHTS`)](https://keithp.com/blogs/fd-passing/)
act as a secure substitute.

With cloudlibc, we've explicitly made the choice to omit these
incompatible features. The disadvantage is that this breaks the build of
many conventional pieces of software. The advantage, however, is that
if you manage to build a certain piece of code, you can be confident
that it works well, even when sandboxed. Compiler errors serve as a
to-do list of code that still need to be ported.

To get a good idea of which features are present and absent, it is wise
to read through [cloudlibc's header files](https://github.com/NuxiNL/cloudlibc/tree/master/src/include).
Almost all of these header files have documentation at the top,
providing a rationale for which features are implemented. It may also be
useful to take a look at
[some of the existing packages](https://github.com/NuxiNL/cloudabi-ports/tree/master/packages)
to see how they have been patched up.
