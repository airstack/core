#SHELL = /bin/bash
NAME = $(notdir $(realpath ../../))/$(notdir $(CURDIR))
VERSION = latest
SHORTNAME = $(notdir $(CURDIR))
ROOTDIR = $(realpath .)
USERNAME = $(notdir $(realpath ../../))
RAWDISK = $(shell mount | grep airstack | cut -d ' ' -f 1 )
uname_S = $(shell sh -c 'uname -s 2>/dev/null || echo not')

.PHONY: all dockerfile build test tag_latest release debug run run_daemon init_share

all: build

initdirs::
	@if [ ! -d cache ]; then mkdir cache; fi

init: initdirs
ifeq ($(uname_S),Darwin)
ifneq ($(shell boot2docker status),running)
	$(shell boot2docker up)
endif
export DOCKER_HOST=tcp://$(shell boot2docker ip 2>/dev/null):2375
endif

build: init 
	@docker build --tag $(NAME):$(VERSION) --force-rm .

test:
	env NAME=$(NAME) VERSION=$(VERSION) ./test/runner.sh

tag_latest:
	@docker tag $(NAME):$(VERSION) $(NAME):latest

release: test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"

COMMON_RUNFLAGS = --publish-all --workdir /home/$(USERNAME) --user $(USERNAME) $(NAME):$(VERSION)
# --hostname=$(SHORTNAME)-$(VERSION)
LINUX_RUNFLAGS = --volume $(ROOTDIR)/output:/home/$(USERNAME)/output --volume $(ROOTDIR)/input:/home/$(USERNAME)/input:ro

OSX_RUNFLAGS = --volume $(ROOTDIR)/output:/home/$(USERNAME)/output --volume /home/docker/base0:/home/$(USERNAME)/base0 --volume $(ROOTDIR)/input:/home/$(USERNAME)/input:ro

ifeq ($(uname_S),Darwin)
	OS_SPECIFIC_RUNFLAGS = $(OSX_RUNFLAGS)	
else
	OS_SPECIFIC_RUNFLAGS = $(LINUX_RUNFLAGS)
endif

debug: init
#ifconfig docker0 -multicast && ifconfig docker0 multicast
	$(shell docker rm $(SHORTNAME)-$(VERSION) > /dev/null 2>&1)
	@docker run --rm -i -t $(OS_SPECIFIC_RUNFLAGS) $(COMMON_RUNFLAGS) /bin/bash

run_daemon:
	@docker run $(OS_SPECIFIC_RUNFLAGS) $(COMMON_RUNFLAGS)

run_foreground:
	@echo Press CTRL-C to exit
	@docker run --rm -i -t $(OS_SPECIFIC_RUNFLAGS) $(COMMON_RUNFLAGS) 

run: run_foreground