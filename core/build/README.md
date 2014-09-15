Put scripts in the build directory that are required for building images.

Any script named "core-*" in the build dir will be available during image
builds (e.g. in the Dockerfile).

Changes to the build dir trigger a full rebuild of Docker images. So keep
files and changes in this dir to a minimum.
