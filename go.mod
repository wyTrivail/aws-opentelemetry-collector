module aws-observability.io/collector

go 1.14

require (
	github.com/docker/docker v1.13.1 // indirect
	github.com/jstemmer/go-junit-report v0.9.1 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awsemfexporter v0.0.0
	github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awsxrayexporter v0.4.0
	github.com/pkg/errors v0.9.1
	github.com/spf13/viper v1.6.2
	github.com/stretchr/testify v1.5.1
	go.opentelemetry.io/collector v0.4.1-0.20200629224201-e7a7690e21fc
	go.uber.org/zap v1.13.0
	golang.org/x/sys v0.0.0-20200408040146-ea54a3c99b9b
	gopkg.in/natefinch/lumberjack.v2 v2.0.0
)

replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awsemfexporter => ./pkg/devexporter/awsemfexporter
