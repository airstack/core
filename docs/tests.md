################################################################################

### Doc Status: WIP

The majority of the test suite runs inside of a container and tests basic
functionality and configuration options.

Tests are written in Lua using TDD/BDD style with the
[Telescope framework](https://github.com/norman/telescope).

# Best Practices

- Create tests in /test folder
- Create a new `<MODULE NAME>_spec.lua` file for each module or script being tested
  - Typically, the test file name is the script name + `_spec.lua`
- The first `describe` block is the module name
  - Ex: `describe("json2env", ...`
- Use nested `describe` blocks to indicate a function or feature
  - Ex: `describe("complex arrary", ...`
- Use `it` statements to indicate a specific test
  - Ex: `it("uses _NUM_ in env var name to enumerate array items", ...`
- Limit the number of `assert` calls in each `it`
  - Too many `assert` calls can make it hard to see what actually failed



# References

- [scripting.md](scripting.md#lua) – Lua language references
