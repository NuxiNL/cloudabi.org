---
layout: page
title: Running CloudABI applications on FreeBSD
permalink: /run/freebsd/
---

FreeBSD 11.1 and later have very good support for CloudABI out of the
box. A stock installation ships with a set of kernel modules,
`cloudabi32.ko` and `cloudabi64.ko`, providing support for running
32-bit and 64-bit CloudABI executables, respectively. They both depend
on common code in `cloudabi.ko`. These modules can be loaded on 32-bit
and 64-bit x86 and ARM systems.

Adding the following lines to `/boot/loader.conf` makes FreeBSD load them
during system boot:

```sh
cloudabi32_load="YES"
cloudabi64_load="YES"
```

The latest version of `cloudabi-run` utility can easily be installed
from FreeBSD Ports:

```
pkg install cloudabi-utils
```

Below is an example of how `cloudabi-run` can be invoked to run the C
library's unit tests. Please refer to `cloudabi-run`'s manual page for
more examples.

```sh
pkg install x86_64-unknown-cloudabi-cloudlibc
mkdir tmp-unittest
cloudabi-run /usr/local/x86_64-unknown-cloudabi/bin/cloudlibc-unittests << EOF
%TAG ! tag:nuxi.nl,2015:cloudabi/
---
tmpdir: !file
  path: tmp-unittest
logfile: !fd stdout
EOF
```

**Note:** The unit tests are intended to pass on FreeBSD `CURRENT` and
the stable branches. When using FreeBSD `11.1-RELEASE`, a small number
of unit tests are expected to fail, due to small new features being
added. This is harmless.
