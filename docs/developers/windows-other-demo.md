### Run AOC on Debian and Windows hosts,

If you downloaded a DEB package on a Linux server, change to the directory containing the package and enter the following:
```
sudo dpkg -i -E ./aws-opentelemetry-collector.deb
```
If you downloaded an MSI package on a server running Windows Server, change to the directory containing the package and enter the following:
```
msiexec /i aws-opentelemetry-collector.msi
```