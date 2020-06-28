-include .env

AOC_IMPORT_PATH=aws-observability.io/collector
VERSION := $(shell cat VERSION)
BUILD := $(shell git rev-parse --short HEAD)
PROJECTNAME := $(shell basename "$(PWD)")

# Go related variables.
BGO_SPACE := $(shell pwd)
GOPATH := $(BGO_SPACE)/vendor:$(BGO_SPACE)
BGO_BIN := $(BGO_SPACE)/bin
GOFILES := $(wildcard *.go)
RUN_CONFIG=config.yaml

GIT_SHA=$(shell git rev-parse HEAD)
GIT_CLOSEST_TAG=$(shell git describe --abbrev=0 --tags)
DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')

BUILD_INFO_IMPORT_PATH=$(AOC_IMPORT_PATH)/tools/version

GOBUILD=GO111MODULE=on CGO_ENABLED=0 installsuffix=cgo go build -trimpath

# Use linker flags to provide version/build settings
LDFLAGS=-ldflags "-s -w -X $(BUILD_INFO_IMPORT_PATH).GitHash=$(GIT_SHA) -X $(BUILD_INFO_IMPORT_PATH).Version=$(VERSION) -X $(BUILD_INFO_IMPORT_PATH).Date=$(DATE)"

# Redirect error output to a file, so we can show it in development mode.
STDERR := /tmp/.$(PROJECTNAME)-stderr.txt

## install: Install missing dependencies. Runs `go get` internally. e.g; make install get=github.com/foo/bar
install: binaries

.PHONY: build-linux
build-linux:
	@echo "Build for Linux amd64"
	GOOS=linux GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BGO_SPACE)/build/linux/aoc_linux_amd64 $(BGO_SPACE)/cmd/awscollector

.PHONY: build-darwin
build-darwin:
	@echo "Build for darwin amd64"
	GOOS=darwin GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BGO_SPACE)/build/darwin/aoc_darwin_amd64 $(BGO_SPACE)/cmd/awscollector

binaries:
	GOOS=darwin GOARCH=amd64 $(MAKE) awscollector
	GOOS=windows GOARCH=amd64 $(MAKE) awscollector
	GOOS=linux GOARCH=amd64 $(MAKE) awscollector
	GOOS=linux GOARCH=arm64 $(MAKE) awscollector

.PHONY: build
build:
	@echo "  >  Building binary..."
	GOOS=linux  GOARCH=amd64 GOPATH=$(GOPATH) GOBIN=$(BGO_BIN) go build $(LDFLAGS) -o $(BGO_BIN)/$(PROJECTNAME) $(GOFILES)
	GOOS=linux  GOARCH=arm64 GOPATH=$(GOPATH) GOBIN=$(BGO_BIN) go build $(LDFLAGS) -o $(BGO_BIN)/$(PROJECTNAME) $(GOFILES)
	GOOS=darwin  GOARCH=amd64 GOPATH=$(GOPATH) GOBIN=$(BGO_BIN) go build $(LDFLAGS) -o $(BGO_BIN)/$(PROJECTNAME) $(GOFILES)
	GOOS=windows  GOARCH=amd64 GOPATH=$(GOPATH) GOBIN=$(BGO_BIN) go build $(LDFLAGS) -o $(BGO_BIN)/$(PROJECTNAME) $(GOFILES)

.PHONY: help
help: Makefile
	@echo
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo
.PHONY: all

.PHONY: test

.PHONY: run
run:
	GO111MODULE=on go run --race ./cmd/awscollector/... --config ${RUN_CONFIG}


.PHONY: build

.PHONY: packaging
packaging: package-rpm package-deb

.PHONY: package-deb
package-deb:
	$(BGO_SPACE)/Tool/src/packaging/debian/build_deb_linux.sh

.PHONY: package-rpm
package-rpm:
	-$(BGO_SPACE)/Tool/src/packaging/linux/build_rpm_linux.sh