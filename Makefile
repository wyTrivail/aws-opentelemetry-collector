RUN_CONFIG=default-config.yaml

.PHONY: all

.PHONY: test

.PHONY: run
run:
	GO111MODULE=on go run --race ./cmd/collector/... --config ${RUN_CONFIG}


.PHONY: build