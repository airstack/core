base image for airstack
==========


Debug Mode:

Run /dev/log/ service (socklog-unix) in background, and start at bash prompt:
  - `make CMD="sudo sh -c '{ /etc/runit/2 single &}; bash'" debug"`
Run all services, and if startup fails, exit to prompt:
  - `make CMD="sudo sh -c '/etc/runit/2; bash'" debug`


To run as PID 1:
  - `make USERNAME=root CMD=runit-init debug`
To run in userspace:
  - `make debug`


# Tests

Tests are written as lua busted scripts using BDD style.

[busted documentation](http://olivinelabs.com/busted/)

### Run Tests

```
# In container
cd /package/airstack/test
busted *.lua
```
