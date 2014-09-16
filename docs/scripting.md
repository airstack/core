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


# Shell

Airstack uses /bin/sh instead of /bin/bash to ensure POSIX compatibility and smaller memory usage.

- [Bash FAQ](http://tiswww.case.edu/php/chet/bash/FAQ)
- [BashGuide](http://mywiki.wooledge.org/Arguments)
- [Google Shell Style Guide](https://google-styleguide.googlecode.com/svn/trunk/shell.xml)
- [posix shell scripting](http://pubs.opengroup.org/onlinepubs/009604599/utilities/xcu_chap02.html#tag_02_09_04)
- [posix error codes](http://tldp.org/LDP/abs/html/exitcodes.html#EXITCODESREF)
  - tl;dr users should use exit codes 64-113 only
  - "The author of this document proposes restricting user-defined exit codes to the range 64 - 113 (in addition to 0, for success), to conform with the C/C++ standard. This would allot 50 valid codes, and make troubleshooting scripts more straightforward."
  - http://stackoverflow.com/questions/4419952/difference-between-return-and-exit-in-bash-functions
- posix shell guide for bash devs
  - http://mywiki.wooledge.org/Bashism
  - https://wiki.ubuntu.com/DashAsBinSh
- [bash posix mode](http://www.gnu.org/software/bash/manual/html_node/Bash-POSIX-Mode.html#Bash-POSIX-Mode)
- [bash references](http://www.gnu.org/software/bash/manual/bashref.html)
- [man vs info](http://unix.stackexchange.com/questions/77514/what-is-gnu-info-for)

Use shellcheck on build to ensure we aren't using bashisms
- switch to mksh-static for dash
- http://lowendbox.com/blog/replacing-big-fat-bash-with-dash-for-scripting/
- http://rgeissert.blogspot.com/2012/03/bash-way-is-faster-but-only-with-bash.html


# Lua

- [Lua Manual](http://www.lua.org/manual/5.2/)
- [LuaRocks](https://rocks.moonscript.org) – Lua package manager
- [Intro to Lua](http://cellux.github.io/articles/introduction-to-luajit-part-1/)
- [LuaJIT](http://luajit.org)
- https://github.com/justincormack/ljsyscall/blob/master/examples/vlan.lua
- https://github.com/justincormack/ljsyscall/blob/master/examples/lxc.lua

### Installed Lua Modules

- [luaposix](http://luaposix.github.io/luaposix/docs/modules/posix.html) – posix bindings, including curses
- [Penlight](https://github.com/stevedonovan/Penlight/) – library for strings, tables, map/reduce, OS path
- [LuaFilesystem](http://keplerproject.github.io/luafilesystem/) – unified filesystem library
- [CJSON](http://www.kyne.com.au/~mark/software/lua-cjson-manual.html) – fast json library
- [LuaSocket](http://w3.impa.br/~diego/software/luasocket/) – TCP/UDP library

### Troubleshooting

- [Install luarocks](http://linuxclues.blogspot.com/2014/07/luarocks-install-source-debian-how-to.html) with lua5.2 on debian


# JavaScript

- https://github.com/arturadib/shelljs
