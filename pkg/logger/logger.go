package logger

import (
	"fmt"
	"go.uber.org/zap/zapcore"
	"gopkg.in/natefinch/lumberjack.v2"
	"io"
	"log"
	"os"
	"path/filepath"
	"runtime"
)

var (
	winLogfilePath   = "C:\\ProgramData\\Amazon\\AOCAgent\\Logs\\aws-opentelemetry-collector.log"
	linuxLogfilePath = "/opt/aws/aws-opentelemetry-collector/logs/aws-opentelemetry-collector.log"
)
var logfile = getLogFilePath()

var lumberjackLogger = &lumberjack.Logger{
	Filename:   logfile,
	MaxSize:    100, //MB
	MaxBackups: 5,   //backup files
	MaxAge:     7,   //days
	Compress:   true,
}

// GetLumberHook returns lumberjackLogger as a Zap hook
// for processing log size and log rotation
func GetLumberHook() func(e zapcore.Entry) error {
	return func(e zapcore.Entry) error {
		_, err := lumberjackLogger.Write(
			[]byte(fmt.Sprintf("{%+v, Level:%+v, Caller:%+v, Message:%+v, Stack:%+v}\r\n",
				e.Time, e.Level, e.Caller, e.Message, e.Stack)))
		if err != nil {
			return err
		}
		return nil
	}
}

// SetupErrorLogger setup lumberjackLogger for go logger
func SetupErrorLogger() {
	log.SetFlags(0)
	var writer io.WriteCloser
	if logfile != "" {
		err := os.MkdirAll(filepath.Dir(logfile), 0755)
		if err != nil {
			log.Printf("D! fail to chmod on log file due to : %v \n", err)
		}
		// The codes below should not change, because the retention information has already been published to public doc.
		writer = lumberjackLogger
	} else {
		writer = os.Stderr
	}
	log.SetOutput(writer)
}

//this method retuns the log file path depending on the OS
func getLogFilePath() string {
	if runtime.GOOS == "windows" {
		return winLogfilePath
	} else {
		return linuxLogfilePath
	}
}
