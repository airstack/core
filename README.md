base image on airstack production

WIP!!!

Do not use for development


# TODO

- use ssl for apt-get? apt-transport-https
  - not completely necessary but prevents man-in-the-middle attacks from preventing security updates

TO run as PID 1, use make debug like this: 
  - `make USERNAME=root CMD=runit-init debug`
