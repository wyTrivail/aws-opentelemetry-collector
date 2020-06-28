-include .env

AOC_IMPORT_PATH=aws-observability.io/collector
VERSION := $(shell cat VERSION)
PROJECTNAME := $(shell basename "$(PWD)")

GIT_SHA=$(shell git rev-parse HEAD)
DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')

BUILD_INFO_IMPORT_PATH=$(AOC_IMPORT_PATH)/tools/version

GOBUILD=GO111MODULE=on CGO_ENABLED=0 installsuffix=cgo go build -trimpath

# Use linker flags to provide version/build settings
LDFLAGS=-ldflags "-s -w -X $(BUILD_INFO_IMPORT_PATH).GitHash=$(GIT_SHA) -X $(BUILD_INFO_IMPORT_PATH).Version=$(VERSION) -X $(BUILD_INFO_IMPORT_PATH).Date=$(DATE)"

.PHONY: build
build:
	#GOOS=darwin GOARCH=amd64 $(MAKE) awscollector
	#GOOS=windows GOARCH=amd64 $(MAKE) awscollector
	GOOS=linux GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o ./build/linux/aoc_linux_x86_64 ./cmd/awscollector
	GOOS=linux GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o ./build/linux/aoc_linux_aarch64 ./cmd/awscollector

.PHONY: package-rpm
package-rpm: build
	ARCH=x86_64 DEST=build/packages/linux/amd64 tools/packaging/linux/create_rpm.sh
	ARCH=aarch64 DEST=build/packages/linux/arm64 tools/packaging/linux/create_rpm.sh

.PHONY: clean
clean: 
	rm -rf ./build
