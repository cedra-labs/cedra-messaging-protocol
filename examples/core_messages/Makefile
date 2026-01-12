-include ../../../Makefile.help

.PHONY: artifacts
artifacts: build

.PHONY: build
## Build contract
build:
	cedra move compile --save-metadata

.PHONY: test
## Run tests
test:
	cedra move test
