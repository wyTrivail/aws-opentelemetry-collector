# get the version
$version = Get-Content -Path ./sVERSION -TotalCount 1 | Out-String
$version = $version.TrimEnd("`n")

# create msi
../wix311-binaries/candle.exe -ext ../wix311-binaries/WixUtilExtension.dll ./amazon-cloudwatch-agent.wxs
../wix311-binaries/light.exe -ext ../wix311-binaries/WixUtilExtension.dll ./amazon-cloudwatch-agent.wixobj

# upload to s3
aws s3 cp ./amazon-cloudwatch-agent.msi "s3://build-msi-bucket/$version/amazon-cloudwatch-agent.msi" --acl public-read
