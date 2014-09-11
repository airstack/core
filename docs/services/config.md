################################################################################

### Doc Status: WIP

This doc needs to be updated once the config system is finalized.


See [runtime_config.md](../runtime_config.md) for overriding service config defaults.



### Defaults

Default service config values are stored in config.json files in each service directory.
Non-service section defaults (start, stop, env, name, etc.) are stored in
`vars/defaults.json`

```bash
/etc/airstack
       /vars
           /defaults.json

       /haproxy
           /config.json
       /serf
           /config.json
       ...
```

When the container starts, it looks up config vars in the following order and returns the first available value:

1. `AIRSTACK_RUNTIME_VARS`
2. `/etc/airstack/vars/defaults.json`
3. `/etc/airstack/<service>/config.json` <-- only if applicable


### Services

The services section defines which services should be run.


### Tags

Tags are metadata about a service. They can be applied at the service level or connection/port
level. Port level tags are added to any service level tags.

```javascript
// Example nodejs service section
"services": {
  "nodejs": {
    "listen": [
      {"port": "80", "protocol": "http", "tags": ["http"]},
      {"port": "443", "protocol": "https", "tags": ["https"]}
    ],
    "requires": ["postgres"],
    "tags": ["web", "api"]
  }
}

// Tags for port 80 will be ["web", "api", "http"]
```

#### Requires

If a service config section has a requires key, the container should wait to start the service
until the dependencies are available on the network. For instance, when a nodejs web container
is run, its core services (logger, ssh, serf, etc.) start immediately but the nodejs service
waits to start until a "postgres" service is available. The postgres service could in theory
be run in the same container but more likely is provided by a separate container or server
and detected through serf.



### Example Docker Run

```
docker run --rm -i -t -e 'AIRSTACK_RUNTIME_VARS={"start":{"cmd":"npm start"}}' airstack/nodejs
```



---

## _WIP_: the below stuff is an idea for dynamic configuration of container services


# Container Config Files

A container typically runs one or more services and exposes configuration options via ENV vars and config files.


# Use Case

MySQL container that exposes several configuration options via ENV vars for novice users and a my.cnf for
advanced users.

### ENV vars

- MYSQL_MAX_CONNECTIONS=20
- MYSQL_LOG_LEVEL=warning

Discovery of supported ENV vars is done through inspecting the container's AIRSTACK_OPTIONS ENV var.

```bash
docker inspect 123123
...
"Env": [
   "AIRSTACK_OPTIONS=MYSQL_MAX_CONNECTIONS,MYSQL_LOG_LEVEL"
]
...
```

By convention, ENV vars override the respective config option. It's up to each container to properly
implement this logic in an init script or similar.


### Config Files

For containers that support modification of config files, we need to support something like the following ...

`air config:edit mysql`

This would ...

1. spin up the mysql container
1. inspect the AIRSTACK_CONFIG ENV var
1. via rsync, copy the file or dir specified in AIRSTACK_CONFIG from the container to .airstack/mysql/config
1. open default editor to .airstack/mysql/config

If `.airstack/mysql/config` already exists, the CLI would simply open the editor to the directory.




