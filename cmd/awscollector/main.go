package main

import (
	"aws-observability.io/collector/pkg/defaultcomponents"
	"aws-observability.io/collector/pkg/logger"
	"aws-observability.io/collector/tools/version"
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
		ExeName:  "aws-observability-collector",
		LongName: "AWS Observability Collector",
		Version:  version.Version,
		GitHash:  version.GitHash,
	}

	svc, err := service.New(service.Parameters{
		Factories:            factories,
		ApplicationStartInfo: info,
		ConfigFactory:        cfgFactory,
		LoggingHooks:         []func(entry zapcore.Entry) error{lumberHook},
	})
	handleErr("Failed to construct the application", err)

	err = svc.Start()
	handleErr("Application run finished with error", err)

}
