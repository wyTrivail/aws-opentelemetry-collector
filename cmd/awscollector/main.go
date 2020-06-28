package main

import (
	"aws-observability.io/collector/pkg/defaultcomponents"
	"aws-observability.io/collector/tools/version"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"go.opentelemetry.io/collector/config"
	"go.opentelemetry.io/collector/config/configmodels"
	"go.opentelemetry.io/collector/service"
	"go.opentelemetry.io/collector/service/builder"
	"log"
)

func main() {
	//SetupLogging()
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
	})
	handleErr("Failed to construct the application", err)
	err = svc.Start()
	handleErr("Application run finished with error", err)

}

// Start starts the collector according to the command and configuration
// given by the user.
func Start(rootCmd *cobra.Command) error {
	// From this point on do not show usage in case of error.
	rootCmd.SilenceUsage = true
	return rootCmd.Execute()
}

//func SetupLogging() {
//	log.SetFlags(0)
//	var logfile = "/tmp/aoc.log"
//	var writer io.WriteCloser
//	if logfile != "" {
//		os.MkdirAll(filepath.Dir(logfile), 0755)
//		// The codes below should not change, because the retention information has already been published to public doc.
//		writer = &lumberjack.Logger{
//			Filename:   logfile,
//			MaxSize:    100, //MB
//			MaxBackups: 5,   //backup files
//			MaxAge:     7,   //days
//			Compress:   true,
//		}
//	} else {
//		writer = os.Stderr
//	}
//	log.SetOutput(writer)
//}
