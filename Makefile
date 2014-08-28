# ######################################
# Default vars
#
# Should not need to touch these unless your directory structure differs.

# Deriving names from directory structure.
NAME = $(notdir $(realpath ../../))/$(notdir $(CURDIR))
SHORTNAME = $(notdir $(CURDIR))
ROOTDIR = $(realpath .)

uname_S = $(shell sh -c 'uname -s 2>/dev/null || echo not')

# ######################################

# ######################################
# Runtime overrides
#
# Set these at runtime to override the below defaults.
# e.g.: 
# `make CMD=/bin/bash debug`
# `make USERNAME=root CMD=runit-init debug`
# `make VERSION=debug build

CMD = /bin/sh
USERNAME = airstack
VERSION = latest

# ######################################

.PHONY: all dockerfile build test tag_latest release debug run run_daemon init_share

all: build

#boot2docker functions

repair:
ifeq ($(uname_S),Darwin)
	@printf "\n\
	=====================\n\
	Repairing boot2docker\n\
	=====================\n\
	"
	@printf "\nRemoving existing boot2docker setup..."
	@boot2docker destroy
	@printf "DONE\n"

	@printf "\nInitializing new boot2docker setup..."
	boot2docker init > /dev/null
	@printf "DONE\n"
endif

initdirs::
	@if [ ! -d cache ]; then mkdir cache; fi

init: initdirs
ifeq ($(uname_S),Darwin)
ifneq ($(shell boot2docker status),running)
	@boot2docker up
endif
export DOCKER_HOST=tcp://$(shell boot2docker ip 2>/dev/null):2375
endif

build: init 
	@docker build --tag $(NAME):$(VERSION) --force-rm .

test:
	@env NAME=$(NAME) VERSION=$(VERSION) ./test/runner.sh

tag_latest:
	@docker tag $(NAME):$(VERSION) $(NAME):latest

release: test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"

COMMON_RUNFLAGS = --publish-all --workdir /home/$(USERNAME) --user $(USERNAME) $(NAME):$(VERSION)
LINUX_RUNFLAGS = --volume $(ROOTDIR)/output:/home/$(USERNAME)/output --volume $(ROOTDIR)/input:/home/$(USERNAME)/input:ro
OSX_RUNFLAGS = --volume $(ROOTDIR)/output:/home/$(USERNAME)/output --volume /home/docker/base0:/home/$(USERNAME)/base0 --volume $(ROOTDIR)/input:/home/$(USERNAME)/input:ro

ifeq ($(uname_S),Darwin)
	OS_SPECIFIC_RUNFLAGS = $(OSX_RUNFLAGS)	
else
	OS_SPECIFIC_RUNFLAGS = $(LINUX_RUNFLAGS)
endif

debug: init
	@if [ `boot2docker ssh 'ifconfig docker0 | grep -io multicast | wc -w'` -lt 1 ]; \
		then ifconfig docker0 -multicast && ifconfig docker0 multicast; fi
	@docker rm $(SHORTNAME)-$(VERSION) > /dev/null 2>&1; true
	@docker run --rm -i -t $(OS_SPECIFIC_RUNFLAGS) $(COMMON_RUNFLAGS) $(CMD)

run_daemon:
	@docker run $(OS_SPECIFIC_RUNFLAGS) $(COMMON_RUNFLAGS)

run_foreground:
	@echo Press CTRL-C to exit
	@docker run --rm -i -t $(OS_SPECIFIC_RUNFLAGS) $(COMMON_RUNFLAGS) 

run: run_foreground
