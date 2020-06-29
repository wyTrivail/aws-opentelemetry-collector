package logger

import (
	"fmt"
	"go.uber.org/zap/zapcore"
	"gopkg.in/natefinch/lumberjack.v2"
	"io"
	"log"
	"os"
	"path/filepath"
)

const logfile = "/opt/aws/aws-opentelemetry-collector/logs/aws-opentelemetry-collector.log"

var lumberjackLogger = &lumberjack.Logger{
	Filename:   logfile,
	MaxSize:    100, //MB
	MaxBackups: 5,   //backup files
	MaxAge:     7,   //days
	Compress:   true,
}

func GetLumberHook() func(e zapcore.Entry) error {
	return func(e zapcore.Entry) error {
		lumberjackLogger.Write([]byte(fmt.Sprintf("%+v\r\n", e)))
		return nil
	}
}

func SetupErrorLogger() {
	log.SetFlags(0)
	var writer io.WriteCloser
	if logfile != "" {
		os.MkdirAll(filepath.Dir(logfile), 0755)
		// The codes below should not change, because the retention information has already been published to public doc.
		writer = lumberjackLogger
	} else {
		writer = os.Stderr
	}
	log.SetOutput(writer)
}
