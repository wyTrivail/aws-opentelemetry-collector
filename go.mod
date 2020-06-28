module aws-observability.io/collector

go 1.14

require (
	github.com/docker/docker v1.13.1 // indirect
	github.com/jstemmer/go-junit-report v0.9.1 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awsxrayexporter v0.4.0
	github.com/spf13/cobra v0.0.6
	github.com/spf13/viper v1.6.2
	go.opentelemetry.io/collector v0.4.0
	gopkg.in/natefinch/lumberjack.v2 v2.0.0
)
