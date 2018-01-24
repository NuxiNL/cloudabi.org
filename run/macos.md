---
layout: page
title: Running CloudABI applications on macOS
permalink: /run/macos/
---

It is possible to run CloudABI applications on macOS by making use of
`cloudabi-run`'s integrated sytem call emulator. This makes executables
run at near native speed, translating any system call invocations to
calls into the macOS kernel. The emulator can be enabled by running
`cloudabi-run` with the `-e` flag.

Though this emulator is fairly representative of how applications behave
when run natively, it is important to keep in mind that the emulator is
no more secure than running a native macOS application. The executable
and the emulator run in the same address space.

The latest version of `cloudabi-run` utility can easily be installed
with [Homebrew](https://brew.sh/):

```
brew tap nuxinl/cloudabi
brew install cloudabi-utils
```

Below is an example of how `cloudabi-run` can be invoked to run the C
library's unit tests. Please refer to `cloudabi-run`'s manual page for
more examples.

```sh
brew install x86_64-unknown-cloudabi-cxx-runtime
mkdir tmp-unittest
cloudabi-run -e /usr/local/share/x86_64-unknown-cloudabi/bin/cloudlibc-unittests << EOF
%TAG ! tag:nuxi.nl,2015:cloudabi/
---
tmpdir: !file
  path: tmp-unittest
logfile: !fd stdout
EOF
```

**Note:** The emulator fails to implement some exotic features, such as
support for process-shared mutexes. It may well be the case that some of
the C library's unit tests fail. Feel free to get in touch if you want
to help us get these features implemented!
