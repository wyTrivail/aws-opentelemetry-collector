module aws-observability.io/collector

go 1.14

require (
	github.com/docker/docker v1.13.1 // indirect
	github.com/jstemmer/go-junit-report v0.9.1 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awsemfexporter v0.0.0
	go.opentelemetry.io/collector v0.4.0
)

replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awsemfexporter => /Users/xiami/Documents/workspace/git/opentelemetry-collector-contrib-aws/exporter/awsemfexporter
