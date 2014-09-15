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

local popen = require("popen")
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
  local pid, stdin_fd, stdout_fd, stderr_fd, code = popen.popen3(...)
  local stdout = posix.read(stdout_fd, 10000)
  local stderr = posix.read(stderr_fd, 10000)
  return stdout, stderr, code, pid
end


return as
