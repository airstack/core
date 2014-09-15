--
-- Airstack lua library tests.
--
-- @see /core/lua/airstack.lua
--
-- References:
-- Asserts: http://olivinelabs.com/busted/#asserts
--


local as = require("airstack")


describe("airstack", function()
  describe("exec", function()
    it("calls ls with args and captures output", function()
      local stdout, stderr, code, pid = as.exec("ls", "-la", "/package/airstack")
      assert.is_true(string.len(stdout) > 100)
      assert.are.equals(0, string.len(stderr))
      assert.are.equals(0, code)
      assert.truthy(pid)
    end)
  end)
end)
