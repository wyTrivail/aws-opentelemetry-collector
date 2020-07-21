# Install the required software
mkdir -p .\build\packages\windows\amd64\
choco install wixtoolset --force -y
$env:Path += ";C:\Program Files (x86)\WiX Toolset v3.11\bin"
refreshenv

# create msi
candle -arch x64  .\tools\packaging\windows\aws-opentelemetry-collector.wxs
light .\aws-opentelemetry-collector.wixobj

mv aws-opentelemetry-collector.msi .\build\packages\windows\amd64\