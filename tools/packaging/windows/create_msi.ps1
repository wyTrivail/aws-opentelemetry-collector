# get the version
$Version = Get-Content -Path ./VERSION -TotalCount 1 | Out-String
$Version = $Version.TrimEnd("`n")

# Install the required software
if(-Not (test-path "C:\Program Files (x86)\WiX Toolset v3.11\bin")){
    choco install wixtoolset -y
    echo "::add-path::$WIX\\bin"
    echo "::add-path::C:\\Program Files (x86)\\WiX Toolset v3.11\\bin"
}

# create msi
candle -arch x64  .\tools\packaging\windows\aws-opentelemetry-collector.wxs
light .\aws-opentelemetry-collector.wixobj
mv -f