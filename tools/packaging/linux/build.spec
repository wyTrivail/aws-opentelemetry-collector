Summary:    AWS Opentelemetry Collector
Name:       %{RPM_NAME}
Version:    %{VERSION}
Release:    1
License:    Amazon Software License. Copyright 2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
Group:      Applications/AWS
Source0:    %{RPM_NAME}-%{VERSION}.tar.gz

%description
This package provides daemon of AWS Opentelemetry Collector

%prep
%setup -q

%install
rm -rf ${RPM_BUILD_ROOT}
mkdir -p ${RPM_BUILD_ROOT}
cp -rfa * ${RPM_BUILD_ROOT}

%files
%dir /opt/aws
%dir /opt/aws/aws-opentelemetry-collector
%dir /opt/aws/aws-opentelemetry-collector/bin
%dir /opt/aws/aws-opentelemetry-collector/doc
%dir /opt/aws/aws-opentelemetry-collector/etc
%dir /opt/aws/aws-opentelemetry-collector/logs
%dir /opt/aws/aws-opentelemetry-collector/var
/opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector
/opt/aws/aws-opentelemetry-collector/bin/VERSION
/opt/aws/aws-opentelemetry-collector/LICENSE
/opt/aws/aws-opentelemetry-collector/etc/config.yaml
/etc/init/aws-opentelemetry-collector.conf
/etc/systemd/system/aws-opentelemetry-collector.service
#
/usr/bin/aws-opentelemetry-collector
/etc/amazon/aws-opentelemetry-collector
/var/log/amazon/aws-opentelemetry-collector
/var/run/amazon/aws-opentelemetry-collector

%clean
rm -rf ${RPM_BUILD_ROOT}
