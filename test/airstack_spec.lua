--
-- Airstack lua library tests.
--
-- @see /core/lua/airstack.lua
--
--


local as = require("airstack")


describe("airstack", function()
  describe("exec", function()
    it("call ls with args and capture output", function()
      local stdout, stderr, code, pid = as.exec("ls", "-la", "/package/airstack")
      assert_true(string.len(stdout) > 0)
      assert_equal(0, string.len(stderr))
      assert_equal(0, code)
    end)
  end)
end)
