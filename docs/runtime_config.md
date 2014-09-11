################################################################################

### Doc Status: WIP


# Config

All config vars are passed into the container at runtime via the AIRSTACK_RUNTIME_VARS env var.

### runtime.json

`AIRSTACK_RUNTIME_VARS` is deep merged with default config.json vars in the container and written
to `/etc/airstack/runtime.json`.

### ENV VARS: json2env

For convenience in accessing config vars in a script, each key in runtime.json is parsed out
into files in `/etc/airstack/env` for root keys and `/service/<SERVICE>/env` for service keys.
The contents of the env file are the cooresponding value from runtime.json.

Env files are written for each level of a json key. File contents are json serialized strings.

For service configs, the service name is prepended to the file name.

#### Example "ssh" service config

```json
{
  "some": "thing"
  "config": {
    "test": {
      "debug": true
    }
  }
}
```
Becomes...
```bash
# /service/ssh/env
# FILENAME             -> file contents

SSH_SOME               -> thing
SSH_CONFIG             -> {"test": {"debug": true}}
SSH_CONFIG_TEST        -> {"debug": true}
SSH_CONFIG_TEST_DEBUG  -> true
```

When services are started, `chpst` is used to load the /etc/airstack/env/* and the relevant
service directory env files into env vars. Conceptually, the loaded env vars are global vars
which is why the names are all caps. However, as a convention, only the relevant global vars
are exposed to a script by default.

If a script needs access to another service's vars, it can do any of the following:

- read `/etc/airstack/runtime.json` and parse into a native json object
- use `chpst` to load env vars from /service/<OTHER_SERVICE>/env
  - e.g. `chpst -e /service/<service>/env`




# Running Scripts on Container Start Up

Scripts to run on container start and stop are defined in [.airstack.yml](https://github.com/airstack/cli/blob/master/.airstack.yml).
The typical use case is to start and stop the primary service of the container: node app, node worker, postgres, memcached, etc.

```yaml
# .airstack.yml example
scripts:
  start:
    before: node test.js # just an example
    cmd: node start.js
  stop: node stop.js
mount:
  - ./
```

The above .airstack.yml example mounts the current directory into the container and runs the ./start.js script
on container start.

The CLI passes the script commands to the container by setting the containers AIRSTACK_RUNTIME_VARS env var.


# AIRSTACK_RUNTIME_VARS

Runtime vars are passed into the container by setting the AIRSTACK_RUNTIME_VARS on `docker run`.

AIRSTACK_RUNTIME_VARS is a json object.


```json
// Example base image
AIRSTACK_RUNTIME_VARS = {
  "stop": "echo '[stop]'",
  "env": "development",
  "name": "base",
  "role": "base",
  "cluster": "airstack_cluster",
  "services": {
    "airstack-base": {
      "state": "up",
      "enable": "echo \"enabling service\"",
      "run": "while true; do echo \"HELLO \"airstack-base\"\"; sleep 1; done",
      "check": "true",
      "finish": "echo \"finished\"",
      "disable": "echo \"disabling service\""
    },
    "socklog-unix": {
      "tags": ["logger", "local", "facilities"]
    },
    "socklog-notify": {
      "connect": [
        {
          "ip": "192.168.59.3",
          "port": "514",
          "protocol": "udp",
        }
      ],
      "tags": ["logger", "remote", "syslog"]
    },
    "dropbear": {
      "state": "down", // supervise dropbear but don't start it
      "listen": [{"port": "22", "protocol": "tcp"}],
      "tags": ["ssh"]
    },
    "haproxy": {
      "listen": [{"port": "9999", "protocol": "tcp", "tags": ["statistics"]}],
      "tags:": ["proxy"]
    },
    "serf": {
      "listen": [{"port": "7946", "protocol": "tcp"}],
      "tags": ["autodiscovery", "autoclustering"]
    }
  }
}

// Example nodejs image
AIRSTACK_RUNTIME_VARS = {
  "env": "development",
  "name": "nodejs",
  "role": "nodejs",
  "cluster": "airstack_cluster",
  "services": {
      "airstack-nodejs": {
        "state": "up",
        "enable": "echo \"enabling service\"",
        "run": "cd /home/airstack && npm start",
        "disable": "echo \"disabling service\"",
        "listen": [
          {"port": "80", "protocol": "http", "tags": ["http"]},
          {"port": "443", "protocol": "https", "tags": ["https"]}
        ],
        "requires": ["postgres"],
        "tags": ["web", "api"]
      }
    }
  }
}
```

# Defaults

See [services/config.md]
