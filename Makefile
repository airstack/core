#######################################
# VARIABLES
#
# Set these at runtime to override the below defaults.
# e.g.:
# `make CMD=/bin/bash debug`
# `make USERNAME=root CMD=/bin/bash debug`
# `make VERSION=debug build`
#######################################

# Uncomment when debugging Makefile
# SHELL = sh -xv

TOP_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CURR_DIR := $(notdir $(patsubst %/,%,$(dir $(TOP_DIR))))
uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')

DOCKER_IMAGE_REPO := airstack
DOCKER_IMAGE_NAME := $(CURR_DIR)
DOCKER_IMAGE_VERSION := latest
DOCKER_IMAGE_FULLNAME := $(DOCKER_IMAGE_REPO)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)
USERNAME := airstack
USERDIR := $(USERNAME)

CMD := /bin/bash
CMD_CONSOLE := sh -c "{ /etc/runit/2 &}; chpst -u $(USERNAME) /bin/bash"
CMD_SINGLE := sh -c "{ /etc/runit/2 single &}; chpst -u $(USERNAME) /bin/bash"

USERFLAG := --user $(USERNAME)
USERFLAG_CONSOLE := --user root
COMMON_RUNFLAGS := --publish-all --workdir /home/$(USERDIR) -e HOME=$(USERDIR) $(DOCKER_IMAGE_FULLNAME)
LINUX_RUNFLAGS := --volume $(USERDIR)/output:/home/$(USERDIR)/output --volume $(ROOTDIR)/input:/home/$(USERDIR)/input:ro
OSX_RUNFLAGS := --volume $(ROOTDIR)/output:/home/$(USERDIR)/output --volume /home/docker/base0:/home/$(USERDIR)/base0 --volume $(ROOTDIR)/input:/home/$(USERDIR)/input:ro

ifeq ($(uname_S),Darwin)
	OS_SPECIFIC_RUNFLAGS := $(OSX_RUNFLAGS)
else
	OS_SPECIFIC_RUNFLAGS := $(LINUX_RUNFLAGS)
endif


# .PHONY should include all commands
.PHONY: default all init test build clean clean-force console debug debug-runit-init repair

################################################################################
# GENERAL COMMANDS
################################################################################

default: build

all:
	@echo all
	make build

init:
	@echo init
ifeq ($(uname_S),Darwin)
ifneq ($(shell boot2docker status),running)
	@boot2docker up
endif
export DOCKER_HOST=tcp://$(shell boot2docker ip 2>/dev/null):2375
endif

test:
	@echo test
	make CMD="busted -v --pattern=_spec /package/airstack/test" debug

build: init
	@echo build
	@docker build --rm --tag $(DOCKER_IMAGE_FULLNAME) .

# Build debug image
# Useful for debugging without overwriting airstack/core:latest image.
build-debug:
	@echo build
	make DOCKER_IMAGE_VERSION=debug build

# Build production image without any development packages
# https://github.com/airstack/core/issues/10
build-prod:
	make DOCKER_IMAGE_VERSION=prod build

clean: init
	@echo "Removing docker image tree for $(DOCKER_IMAGE_FULLNAME) ..."
	docker rmi $(DOCKER_IMAGE_FULLNAME)

clean-force: init
	@echo "Removing docker image tree for $(DOCKER_IMAGE_FULLNAME) ..."
	@docker rmi -f $(DOCKER_IMAGE_FULLNAME)

################################################################################
# RUN COMMANDS
################################################################################

console: init
	docker run --rm -it $(OS_SPECIFIC_RUNFLAGS) $(USERFLAG_CONSOLE) $(COMMON_RUNFLAGS) $(CMD_CONSOLE)

console-single: init
	docker run --rm -it $(OS_SPECIFIC_RUNFLAGS) $(USERFLAG_CONSOLE) $(COMMON_RUNFLAGS) $(CMD_SINGLE)

debug: init
	docker run --rm -it $(OS_SPECIFIC_RUNFLAGS) $(USERFLAG) $(COMMON_RUNFLAGS) $(CMD)

run:
	make console

run-daemon: init
	docker run $(OS_SPECIFIC_RUNFLAGS) $(COMMON_RUNFLAGS)


################################################################################
# BOOT2DOCKER CONVENIENCE COMMANDS
################################################################################

repair: init
ifeq ($(uname_S),Darwin)
	@printf "\n\
	=====================\n\
	Repairing boot2docker\n\
	=====================\n\
	"
	@printf "\nTurning off existing boot2docker VMs..."
	@boot2docker poweroff
	@printf "DONE\n"

	@printf "\nRemoving existing boot2docker setup..."
	@boot2docker destroy
	@printf "DONE\n"

	@printf "\nInitializing new boot2docker setup..."
	boot2docker init > /dev/null
	@printf "DONE\n"
endif
