# Makefile Examples


### Built-in Makefile Stuff

```bash
# Full path of current directory; defined by make
$CURDIR

# Expand and set var now: ':='
VAR := $(OTHERVAR)

# Expand var when used: '='
OTHERVAR = 1
VAR = $(OTHERVAR)
OTHERVAR = 2
echo $(VAR)  # => 2

# Set var if not already defined: '?='
VAR ?= true
```


### Useful Snippets

```bash
# Get current working directory name
$(notdir $(CURDIR))

# Get current directory of Makefile; useful for sub-make.
# Example: /first/dir/Makefile calls /other/dir/Makefile
# DIR will will be /other/dir/
DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Get name of parent directory
CURR_DIR := $(notdir $(patsubst %/,%,$(dir $(CURDIR))))

# Call a shell command
uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')
```
