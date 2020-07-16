package logger

import (
	"go.uber.org/zap/zapcore"
)



// GetLumberHook returns lumberjackLogger as a Zap hook
// for processing log size and log rotation
func GetLumberHook() func(e zapcore.Entry) error {
	return GetNewLumberHook()
}

// SetupErrorLogger setup lumberjackLogger for go logger
func SetupErrorLogger() {
	SetupNewErrorLogger()
}
