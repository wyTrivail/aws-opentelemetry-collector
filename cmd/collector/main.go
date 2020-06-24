package main

import (
	"aws-observability.io/collector/pkg/defaultcomponents"
	"log"

	"aws-observability.io/collector/tools/version"
	"go.opentelemetry.io/collector/service"
)

func main() {
	handleErr := func(message string, err error) {
		if err != nil {
			log.Fatalf(
				"%s: %v", message, err)
		}
	}

	factories, err := defaultcomponents.Components()
	handleErr("Failed to build components", err)

	info := service.ApplicationStartInfo{
		ExeName:  "aws-observerbility-collector",
		LongName: "AWS Obsvervability Collector",
		Version:  version.Version,
		GitHash:  version.GitHash,
	}

	svc, err := service.New(service.Parameters{Factories: factories, ApplicationStartInfo: info})
	handleErr("Failed to construct the application", err)

	err = svc.Start()
	handleErr("Application run finished with error", err)

}
