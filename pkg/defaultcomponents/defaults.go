package defaultcomponents

import (
	"github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awsemfexporter"
	"github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awsxrayexporter"
	"go.opentelemetry.io/collector/component"
	"go.opentelemetry.io/collector/component/componenterror"
	"go.opentelemetry.io/collector/config"
	"go.opentelemetry.io/collector/exporter/fileexporter"
	"go.opentelemetry.io/collector/exporter/loggingexporter"
	"go.opentelemetry.io/collector/exporter/otlpexporter"
	"go.opentelemetry.io/collector/exporter/prometheusexporter"
	"go.opentelemetry.io/collector/service/defaultcomponents"
)

// Components register Otel components for AOC distribution
func Components() (config.Factories, error) {
	errs := []error{}
	factories, err := defaultcomponents.Components()
	if err != nil {
		return config.Factories{}, err
	}

	// Reset the default exporters
	for k := range factories.Exporters {
		delete(factories.Exporters, k)
	}

	exporters := []component.ExporterFactoryBase{
		&awsxrayexporter.Factory{},
		&awsemfexporter.Factory{},
		&prometheusexporter.Factory{},
		&loggingexporter.Factory{},
		&fileexporter.Factory{},
		&otlpexporter.Factory{},
	}

	factories.Exporters, err = component.MakeExporterFactoryMap(exporters...)
	if err != nil {
		errs = append(errs, err)
	}

	return factories, componenterror.CombineErrors(errs)
}
