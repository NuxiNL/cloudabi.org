---
layout: page
title: Introducing CloudABI
---

## What is CloudABI?

CloudABI is a runtime environment for UNIX-like operating systems.
Applications built for CloudABI differ from traditional UNIX-like
applications in that they do not make use of
[command-line arguments](https://en.wikipedia.org/wiki/Command-line_interface#Arguments)
and
[environment variables](https://en.wikipedia.org/wiki/Environment_variable).
Instead, they can be launched through a utility called `cloudabi-run`,
which can read configuration options provided in
[YAML](https://en.wikipedia.org/wiki/YAML):

```
$ cat my_webserver.yaml
vhosts:
- domain: cloudabi.org
  ...
worker_processes: 20
max_concurrent_connections: 500
$ cloudabi-run /path/to/webserver/executable < my_webserver.yaml
```

CloudABI applications can then retrieve these options from within their
entry point function (for C/C++: `program_main()` instead of `main()`):

```c++
#include <argdata.hpp>
#include <program.h>

void program_main(const argdata_t *ad) {
  int worker_processes = 30; // Default value.
  for (auto [key, value] : ad->as_map()) {
    if (key->as_str() == "worker_processes")
      worker_processes = value->as_int<int>();
  }
  ...
}
```

What is special about the YAML supported by `cloudabi-run` is that it
may contain [YAML tags](http://www.yaml.org/spec/1.2/spec.html#id2761292)
that refer to external resources, such as files, directories on and
network sockets:

```yaml
%TAG ! tag:nuxi.nl,2015:cloudabi/
---
vhosts:
- domain: cloudabi.org
  root_directory: !file
    path: /var/www/cloudabi.org
    ...
```

These resources are acquired by `cloudabi-run` and can be extracted by
the application as file descriptors, meaning program startup can be
simplified.

Direct access to global namespaces is absent from CloudABI entirely,
meaning applications cannot open files or connect to systems on the
network arbitrarily. **In effect, resources specified in the YAML file
(and ones derived from them) are the only ones CloudABI applications can
use to interact with the outside world.** There is no need to design a
separate security policy.

The idea behind CloudABI is that we want to work towards a landscape in
which applications are **strongly sandboxed**, **testable** and
**reusable** by default. It brings the concept of
[dependency injection](https://en.wikipedia.org/wiki/Dependency_injection)
to full-size UNIX applications by making use of
[capability-based security](https://en.wikipedia.org/wiki/Capability-based_security).
The goal is to make sandboxing **clean** and **simple**, as opposed to
being an obstacle.

## Using CloudABI

### I want to write CloudABI applications in...

It is possible to write software for CloudABI in a number of languages.
The articles linked below explain how you can get started with
developing software in your language of choice.

- [C and C++](write/c/)
- JavaScript (Node.js) (Coming soon!)
- [Python](write/python/)
- [Rust](write/rust/)

If your favorite language is not listed, it means we're still looking
for volunteers to help us add support!

### I want to run CloudABI applications on...

By formally defining CloudABI's system call interface and making the
runtime friendly towards embedding, it is possible to run CloudABI
executables on multiple operating systems without modification. For
example, a CloudABI application compiled on macOS can be run on FreeBSD
and Linux as well.

The following articles explain how `cloudabi-run` can be set up on your
operating system of choice.

- [FreeBSD](run/freebsd/)
- [Linux](run/linux/)
- [macOS](run/macos/)

If your favorite operating system is not listed, it means we're still
looking for volunteers to help us port CloudABI to that system! Use of
CloudABI as part of experimental operating systems research is also
encouraged.

## Projects under the CloudABI umbrella

- **[CloudABI](https://github.com/NuxiNL/cloudabi)**<br/>
  Specification of the system call layer that CloudABI applications use
  to interact with the operating system. This specification is
  automatically converted into documentation and language bindings.
- **[cloudlibc](https://github.com/NuxiNL/cloudlibc)**<br/>
  Standard C library for CloudABI that implements a large part of C11
  and POSIX 2008. All features that are incompatible with CloudABI's
  security model have been removed, making it easy to determine which
  parts of software needs to be adjusted to work well with sandboxing.
- **[CloudABI Ports](https://github.com/NuxiNL/cloudabi-ports)**<br/>
  Collection of recipes for cross compiling Open Source Software for
  CloudABI. All of these recipes are built and exported as packages in
  various formats (`.deb`, `.rpm`, Homebrew, etc.),
  [which makes them easy to install on your development system](ports/).
- **[Flower](https://github.com/NuxiNL/flower)**<br/>
  A networking daemon that can facilitate network connections between
  CloudABI (and non-CloudABI) applications. Just like CloudABI itself,
  it uses a capability-like security model for binding and connecting.
- **[Scuba](https://github.com/NuxiNL/scuba)**<br/>
  [Container Runtime Interface](http://blog.kubernetes.io/2016/12/container-runtime-interface-cri-in-kubernetes.html)
  daemons for running CloudABI applications directly on top of
  [Kubernetes](https://kubernetes.io/) without the need for Docker
  containers.
- **[Argdata](https://github.com/NuxiNL/argdata)** and
  **[ARPC](https://github.com/NuxiNL/arpc)**<br/>
  Serialization format and RPC layer capable of transparently forwarding
  file descriptors between UNIX processes.
- **[CloudABI demo web server](https://github.com/NuxiNL/cloudabi-demo-webserver)**<br/>
  Example web server for CloudABI, written in C++, making use of Flower
  for networking.

## Getting in touch

Discussion regarding CloudABI takes place on various media:

- **IRC**<br/>
  There is an IRC channel,
  [`#cloudabi` on EFNet](http://chat.efnet.org:9090/?channels=%23cloudabi) (`irc.efnet.org`)
  where active discussions regarding the use and development of CloudABI
  take place.
- **Google Groups**<br/>
  A mailing list,
  [cloudabi-devel@googlegroups.com](mailto:cloudabi-devel@googlegroups.com),
  exists. Its archives can be accessed through
  [Google Groups](https://groups.google.com/forum/#!forum/cloudabi-devel).
- **GitHub**<br/>
  Feel free to file issues on [GitHub](http://github.com/NuxiNL) in case
  you have questions!

## The CloudABI project needs your help!

Though a lot has already been achieved since the CloudABI project was
founded (2015), the project needs both a larger group of users and
developers to flourish. Are you interested helping out? Get in touch!
Non-technical contributions to the project (e.g., promotion, design,
documentation) are appreciated as well!

CloudABI consists entirely of Free/Open Source Software (FOSS). All of
the source code developed as part of the project is released on
[GitHub](http://github.com/NuxiNL) under a two-clause BSD license.
