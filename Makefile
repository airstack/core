AIRSTACK_IMAGE_NAME := airstack/core
AIRSTACK_BUILD_TEMPLATES_PRODUCTION := Dockerfile.base Dockerfile.packages Dockerfile.services
AIRSTACK_BUILD_TEMPLATES_DEVELOPMENT := Dockerfile.base Dockerfile.packages Dockerfile.packages.development Dockerfile.services Dockerfile.services.development Dockerfile.services.tests
AIRSTACK_BUILD_TEMPLATES_TEST := $(AIRSTACK_BUILD_TEMPLATES_DEVELOPMENT)

BOOTSTRAPPED := $(shell [ -d ~/.airstack/bootstrap ] && echo 'yes' || echo 'no')
ifeq ($(BOOTSTRAPPED),yes)
include ~/.airstack/bootstrap/Makefile
else
bootstrap:
	@echo bootstrap
	# TODO: maybe add -L if it's secure; better to use GPG and sign the install script
	curl -s https://raw.githubusercontent.com/airstack/bootstrap/master/install | sh -e
endif
