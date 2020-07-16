# get the version
$Version = Get-Content -Path ./VERSION -TotalCount 1 | Out-String
$Version = $Version.TrimEnd("`n")
$Config="./config.yaml"

# Install the required software
$testchoco = choco -v
if(-not($testchoco)){
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
if(-Not (test-path "C:\Program Files (x86)\WiX Toolset v3.11\bin")){
    choco install wixtoolset -y
    setx /m PATH "%PATH%;C:\Program Files (x86)\WiX Toolset v3.11\bin"
    refreshenv
}

# create msi
candle -arch x64 -dVersion="$Version" -dConfig="$Config"  .\tools\packaging\windows\aws-opentelemetry-collector.wxs
light aws-opentelemetry-collector.wixobj
Move-Item -Force aws-opentelemetry-collector.msi bin/aws-opentelemetry-collector.msi