// +build windows

package main

import (
	"github.com/pkg/errors"
	"golang.org/x/sys/windows/svc"

	"go.opentelemetry.io/collector/service"
)

func run(params service.Parameters) error {
	isInteractive, err := svc.IsAnInteractiveSession()
	if err != nil {
		return errors.Wrap(err, "failed to determine if we are running in an interactive session")
	}

	if isInteractive {
		return runInteractive(params)
	} else {
		return runService(params)
	}
}

func runService(params service.Parameters) error {
	// do not need to supply service name when startup is invoked through Service Control Manager directly
	if err := svc.Run("", service.NewWindowsService(params)); err != nil {
		return errors.Wrap(err, "failed to start service")
	}

	return nil
}
