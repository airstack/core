base image for airstack
==========


Debug Mode:
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
