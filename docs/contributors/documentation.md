################################################################################

Airstack/core uses a modified versions of [JavaDoc](http://javaworkshop.sourceforge.net/chapter4.html#Javadoc+Comments)
syntax for documenting code.


# Code Documentation

Order of function [comment tags](http://javaworkshop.sourceforge.net/chapter4.html#N10228):
```
@author
@version
@param
@return
@throws
@see
@since
@deprecated
```

Tags that can appear multiple times:
```
@author
@param
@throws
```


# Shell Scripts

### Function Headers

Use three hashes and one star `###*` to start function documentation block.
Three hashes to end the block.
No spaces after comment block and function.
At least two spaces before comment block and any code above it.

```bash
###*
# Short description sentence.
#
# Long description paragraph with line wraps before 80 chars.
# Long description can be multiple sentences and paragraphs.
#
# @param varname  Description of var
# @return
#   0 on success
#   1 on error
# @see path/to/file/in/repo
# @see path/file#lowercase-header-in-file
###
some_function() {}
```

### Section Headers

For long script files that cannot be divided into functions, use section
headers to visually divide the file.

A section header is 80 hashes long.

```bash
################################################################################
# Section Header
################################################################################
```

See [Dockerfile](/Dockerfile) for example.



# Other References

- http://stackoverflow.com/questions/1190427/shell-documentation-bash-ksh
- http://javaworkshop.sourceforge.net/chapter4.html#Javadoc+Comments
- https://google-styleguide.googlecode.com/svn/trunk/shell.xml



