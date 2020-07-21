# get the version
$Version = Get-Content -Path ./VERSION -TotalCount 1 | Out-String
$Version = $Version.TrimEnd("`n")

# Install the required software
choco install wixtoolset -y
echo "::add-path::$WIX\\bin"
echo "::add-path::C:\\Program Files (x86)\\WiX Toolset v3.11\\bin"

# create msi
candle -arch x64  .\tools\packaging\windows\aws-opentelemetry-collector.wxs
light .\aws-opentelemetry-collector.wixobj

# mv msi the build folder
mv aws-opentelemetry-collector.msi .\build\packages\windows\amd64\
