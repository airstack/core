################################################################################

### Doc Status: WIP



## Building a docker image

example:
```
cat Dockerfile_airstack Dockerfile_user | docker build -
```

Docs:

The files at PATH or URL are called the "context" of the build. The build process may refer to any of the files in the context, for example when using an ADD instruction. When a single Dockerfile is given as URL or is piped through STDIN (docker build - < Dockerfile), then no context is set.

-e /etc/runit/env -e /service/{servicename}/env

###
Dockerfile structure:

Airstack level:
- packages
- userland setup (runit etc.)
- custom scripts

User level:
- packages
- custom scripts

