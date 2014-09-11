################################################################################

### Doc Status: WIP

Airstack aims to make developers and devops more productive. One of the biggest productivity
impediments with servers is dealing with inconsistent tool versions and limitations of
shell scripting languages.

Airstack will provide a universally available scripting language for configuring and
managing services. This is experimental and WIP.


# Overview

Bash/sh is great for universal install but sucks for productivity.

Airstack is an opionated framework for sysadmin automation.
It guarantees certain tools and API interfaces across systems.

Since bash sucks for productivity, Airstack provides a higher level scripting framework.


# Language Comparison

- python: commonly installed by default on most *nix distros but broken API between 2.6 and 3
- ruby: not installed by default
- perl: installed by default but fading popularity
- lua: tiny footprint but not yet commonly used for sysadmin scripting
- javascript: popular but 10mb+ memory overhead per script and not installed by default

### References
- [Lua vs Python](http://lua-users.org/wiki/LuaVersusPython)
- [Martin Fowler language comparison](http://martinsprogrammingblog.blogspot.com/2013/01/embedding-new-runtime-into-your-legacy.html?m=1)



# Lua

- [Lua Manual](http://www.lua.org/manual/5.2/)
- [Lua CJSON](http://www.kyne.com.au/~mark/software/lua-cjson-manual.html) – [fast json](http://lua-users.org/wiki/JsonModules) implementation for lua
- https://github.com/stevedonovan/Penlight/
- http://cellux.github.io/articles/introduction-to-luajit-part-1/
- https://github.com/justincormack/ljsyscall/blob/master/examples/vlan.lua
- https://github.com/justincormack/ljsyscall/blob/master/examples/lxc.lua
- [LuaRocks](http://luarocks.org/en/Rockspec_format) – Lua package manager
- [LuaJIT](http://luajit.org/install.html)


# JavaScript

- https://github.com/arturadib/shelljs
