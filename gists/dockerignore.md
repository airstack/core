# Example .dockerignore

.dockerignore is not the same format as .gitignore.

Patterns in .dockerignore are fed to go's filepath.match method.
Nested directories must be specifically matched unlike .gitignore.

See [https://golang.org/src/pkg/path/filepath/match_test.go]


```bash

.git
.gitignore
.dockerignore
.airstackignore
.DS_Store
build/
_wip

# Exclude dot files and dot dirs in nested directories.
# This will exclude .DS_Store files in nested directories up to
# six levels deep. Note that .* is not allowed as this will
# break go's filepath pattern matching.
*/.*
*/*/.*
*/*/*/.*
*/*/*/*/.*
*/*/*/*/*/.*
*/*/*/*/*/*/.*
```
