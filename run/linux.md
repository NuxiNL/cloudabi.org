---
layout: page
title: Running CloudABI applications on Linux
permalink: /run/linux/
---

[Support for running CloudABI executables on Linux natively](https://github.com/NuxiNL/linux)
was developed in 2016 by making use of
[the Capsicum Linux patchset](https://github.com/google/capsicum-linux).
Unfortunately, the Capsicum patchset has never been upstreamed into the
official kernel sources, meaning that it's currently not possible to
provide support for CloudABI through a loadable kernel module.

We therefore recommend running CloudABI applications on Linux by making
use of `cloudabi-run`'s integrated sytem call emulator. This makes
executables run at near native speed, translating any system call
invocations to calls into the Linux kernel. The emulator can be enabled
by running `cloudabi-run` with the `-e` flag.

Though this emulator is fairly representative of how applications behave
when run natively, it is important to keep in mind that the emulator is
no more secure than running a native Linux application. The executable
and the emulator run in the same address space.

The latest version of `cloudabi-run` utility can easily be installed
as follows. We're still interested in having packages upstreamed for
systems not listed below...

- **Arch Linux**
  ```
pacman -S cloudabi-utils
```
- [**Debian-based Docker container**](https://github.com/NuxiNL/debian-cloudabi)
  ```
git clone https://github.com/NuxiNL/debian-cloudabi.git
cd debian-cloudabi
docker build .
docker run -ti ... /bin/sh
```

Below is an example of how `cloudabi-run` can be invoked to run the C
library's unit tests. Please refer to `cloudabi-run`'s manual page for
more examples.

```sh
apt-get install x86-64-unknown-cloudabi-cxx-runtime
mkdir tmp-unittest
cloudabi-run -e /usr/x86_64-unknown-cloudabi/bin/cloudlibc-unittests << EOF
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
