# get the version
$Version = Get-Content -Path ./VERSION -TotalCount 1 | Out-String
$Version = $Version.TrimEnd("`n")

# create msi
candle -arch x64  .\tools\packaging\windows\aws-opentelemetry-collector.wxs
light .\aws-opentelemetry-collector.wixobj

# mv msi the build folder
mv aws-opentelemetry-collector.msi .\build\packages\windows\amd64\
