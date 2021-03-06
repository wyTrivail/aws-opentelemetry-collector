package main

import (
	"aws-observability.io/collector/pkg/defaultcomponents"
	"aws-observability.io/collector/pkg/logger"
	"aws-observability.io/collector/tools/version"
	"github.com/pkg/errors"
	"github.com/spf13/viper"
	"go.opentelemetry.io/collector/config"
	"go.opentelemetry.io/collector/config/configmodels"
	"go.opentelemetry.io/collector/service"
	"go.opentelemetry.io/collector/service/builder"
	"go.uber.org/zap/zapcore"
	"log"
)

func main() {
	logger.SetupErrorLogger()
	handleErr := func(message string, err error) {
		if err != nil {
			log.Fatalf(
				"%s: %v", message, err)
		}
	}

	factories, err := defaultcomponents.Components()
	handleErr("Failed to build components", err)

	// configuration factory
	cfgFactory := func(otelViper *viper.Viper, f config.Factories) (*configmodels.Config, error) {
		// use the default config
		if len(builder.GetConfigFile()) == 0 {
			handleErr("configuration file is not provided", nil)
			// TODO - load default config?
		}
		// use OTel yaml config from input
		otelCfg, err := service.FileLoaderConfigFactory(otelViper, f)
		if err != nil {
			return nil, err
		}
		return otelCfg, nil
	}

	lumberHook := logger.GetLumberHook()
	info := service.ApplicationStartInfo{
		ExeName:  "aws-opentelemetry-collector",
		LongName: "AWS OpenTelemetry Collector",
		Version:  version.Version,
		GitHash:  version.GitHash,
	}

	if err := run(service.Parameters{
		Factories:            factories,
		ApplicationStartInfo: info,
		ConfigFactory:        cfgFactory,
		LoggingHooks:         []func(entry zapcore.Entry) error{lumberHook}}); err != nil {
		log.Fatal(err)
	}

}

func runInteractive(params service.Parameters) error {
	app, err := service.New(params)
	if err != nil {
		return errors.Wrap(err, "failed to construct the application")
	}

	err = app.Start()
	if err != nil {
		return errors.Wrap(err, "application run finished with error: %v")
	}

	return nil
}
