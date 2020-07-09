package defaultcomponents

import (
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"testing"
)

func TestComponents(t *testing.T) {
	factories, err := Components()
	require.NoError(t, err)
	exporters := factories.Exporters
	// aws exporters
	assert.True(t, exporters["awsxray"] != nil)
	// core exporters
	assert.True(t, exporters["logging"] != nil)
	assert.True(t, exporters["otlp"] != nil)

	receivers := factories.Receivers
	assert.True(t, receivers["otlp"] != nil)
	assert.True(t, receivers["prometheus"] != nil)

	extensions := factories.Extensions
	assert.True(t, extensions["pprof"] != nil)
	assert.True(t, extensions["health_check"] != nil)
	assert.True(t, extensions["zpages"] != nil)

	processors := factories.Processors
	assert.True(t, processors["memory_limiter"] != nil)
}
