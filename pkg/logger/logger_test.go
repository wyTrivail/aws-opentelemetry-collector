package logger

import (
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/zap/zapcore"
	"gopkg.in/natefinch/lumberjack.v2"
	"log"
	"testing"
)

func TestGetLumberHook(t *testing.T) {
	entry := zapcore.Entry{
		Message: "test",
	}
	funcCall := GetLumberHook()
	err := funcCall(entry)
	require.NoError(t, err)
}

func TestSetupErrorLogger(t *testing.T) {
	SetupErrorLogger()
	_, ok := log.Writer().(*lumberjack.Logger)
	assert.True(t, ok)
}
