################################################################################

# Overview

Aircore is the base image for [Airstack](http://www.airstack.io) containers.

Airstack is an opinionated devops framework for building modern, scalable app
clusters out of lightweight microservices. It aims to make developing and
deploying distributed apps as fun and painless as possible for both developers
and devops. Aircore can be used independently of other Airstack tools.

Airecore is meant to always be extended to provide additional services:
NodeJS, Ruby, PostgreSQL, Redis, etc.

Aircore provides the following core services:

- Distro independent package and configuration standards
- JSON templating for service config defaults and runtime overrides
- Service initialization
  - starting, stopping, monitoring, dependency management, etc.
- Networking
  - firewall configuration
  - container discovery
- Logging
- SSH
- POSIX scripting library
  - package installation
  - error handling
- Lua scripting library
- Test framework

Aircore services are guaranteed to be available in all Aircore compatible
containers regardless of the underlying operating system.


# Philosophy

Aircore is designed with
[Unix](http://en.wikipedia.org/wiki/Unix_philosophy) and
[microserve architecture](http://en.wikipedia.org/wiki/Service-oriented_architecture)
principles in mind.

While an Aircore-based container can run anything supported by the underlying
OS, Aircore aims to advance the state-of-the-art by encouraging "single purpose"
containers in a microservice architecture. A container should only run a few
core services (logging, networking, monitoring, etc.) and one main service:
e.g. an app's NodeJS HTTP API. Services like datastore backends, background
workers, image processing nodes, etc. should all be run in separate containers.

Traditionally, microservice architectures are hard to develop due to all of the
development dependencies. A developer on her laptop needs to independently
start PostgreSQL, Redis, Memcached, several apps for responding to different
HTTP requests, one or more background workers, and so on. Then a watcher daemon
needs to run to restart or reload each service on code change. By using Virtual
Machines and containers, each service can be safely run in its own environment.
Aircore's microservice design philosophies help ensure the overhead of each
container is as small as possible. The Airstack tools make it easy to
orchestrate and run all the services in development, test, and production
environments.

Aircore's design philosophy is akin to
[Rails](http://en.wikipedia.org/wiki/Ruby_on_Rails#Philosophy_and_design):
convention over configuration. In other words, there's one "best way" to do
things. But there's also a well documented, lower level API when needed.

For developers, Aircore makes all the hard devops choices so the developer can
focus on app development. For devops, Aircore provides best practices, a clear
mental model, and predictable patterns so the devop can focus on mission
critical infrastructure decisions.

### Design Concerns

- Microservice architecture
- Small image disk footprint: <200MB
- Small memory + cpu footprint of core services
- Short lived processes for non-daemon scripts
- Common tools across distros
- Opinionated micro framework vs universal swiss army knife
- Intuitive, simple mental model
- Aggressively opinionated best practices for core services
- Clear separation of framework vs underlying tools
- 80/20 rule
  - super simple for 80% use cases
  - easily extensible for 20% use cases
- Support [12 factor apps](http://12factor.net/)


# Controversies

The *nix (Unix/Linux) world is not without its controversies. Many open source
projects live and die by which philosophical camp they belong to.

################################################################################
There are a few raging debates in the devops world that were taken into careful
consideration when building Aircore:

- Systemd vs The World
  - Aircore uses runit
  – See [init_system.md](init_system.md)
- Containers vs Virtual Machines
  - Aircore currently builds Docker containers
  - Aircore is an abstraction layer that will support VMs in the future
- Security of Docker
  - Aircore enforces security best practices for containers
  - See [security.md](security.md)
- Unix Tools vs Go
  - Many existing devop tools are being rewritten in [golang](http://golang.org/)
  - Aircore uses existing unix tools when possible
  - Pros:
    - Better adherence to Unix principles
    - Smaller memory footprint
      - go programs typically use a minimum of 10MB due to the VM
    - Stability and simplicity
  - Cons:
    - Existing tools limit Aircore to fewer base OS's

