#!/usr/bin/env lua
--
-- Wrapper module for common system functions in Lua.
--
-- Use this module instead of the built-in Lua library or other libraries
-- to ensure a consistent API for future releases.
--
-- Usage:
-- local as = require("airstack")
--

-- Add core/lua directory to require path
package.path = package.path .. ";/package/airstack/core/lua/?.lua"

local posix = require("posix")

-- Module returned at end of script
local as = {}


--------------------------------------------------------------------------------
-- BEGIN PUBLIC FUNCTIONS
--------------------------------------------------------------------------------

--
-- Execute a program using a shell.
--
-- Calls popen3 and returns strings instead of file descriptors.
-- Only the first 10,000 chars are returned in stdout and stderr.
--
-- @param cmd     Command to exec
-- @params args   One or more args to pass to exec
-- @return multi  stdout, stderr, exit_code, pid
-- @throws        When command fails
function as.exec(...)
  local pid, stdin_fd, stdout_fd, stderr_fd, code = as.popen3(...)
  local stdout = posix.read(stdout_fd, 10000)
  local stderr = posix.read(stderr_fd, 10000)
  return stdout, stderr, code, pid
end

-- popen3
-- Modified from https://github.com/kylemanna/lua-popen3
function as.popen3(path, ...)
  local r1, w1 = posix.pipe()
  local r2, w2 = posix.pipe()
  local r3, w3 = posix.pipe()
  assert((w1 ~= nil and r2 ~= nil and r3 ~= nil), "pipe() failed")
  local pid, err = posix.fork()
  assert(pid ~= nil, "fork() failed")
  if pid == 0 then
    posix.close(w1)
    posix.close(r2)
    posix.close(r3)
    posix.dup2(r1, posix.fileno(io.stdin))
    posix.dup2(w2, posix.fileno(io.stdout))
    posix.dup2(w3, posix.fileno(io.stderr))
    local ret, err = posix.execp(path, ...)
    assert(ret ~= nil, "execp() failed")
    posix._exit(ret)
    return
  end
  local cpid, status, code = posix.wait()
  posix.close(r1)
  posix.close(w2)
  posix.close(w3)
  return pid, w1, r2, r3, code
end


return as
