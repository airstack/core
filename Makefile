BOOTSTRAPPED := $(shell [ -d ~/.airstack/bootstrap ] && echo 'yes' || echo 'no')
ifeq ($(BOOTSTRAPPED),yes)
include ~/.airstack/bootstrap/Makefile
else
bootstrap:
	@echo bootstrap
	# TODO: maybe add -L if it's secure; better to use GPG and sign the install script
	curl -s https://raw.githubusercontent.com/airstack/bootstrap/master/install | sh -e
endif
