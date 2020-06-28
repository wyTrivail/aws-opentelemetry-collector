Summary:    AWS Opentelemetry Collector
Name:       aoc
Version:    %{VERSION}
Release:    1
License:    Amazon Software License. Copyright 2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
Group:      Applications/AWS
Source0:    aoc-%{VERSION}.tar.gz

%description
This package provides daemon of AWS Opentelemetry Collector

%prep
%setup -q

%install
cp -rfa * %{buildroot}

%files
%dir /opt/aws
%dir /opt/aws/aws-opentelemetry-collector
%dir /opt/aws/aws-opentelemetry-collector/bin
%dir /opt/aws/aws-opentelemetry-collector/doc
%dir /opt/aws/aws-opentelemetry-collector/etc
%dir /opt/aws/aws-opentelemetry-collector/logs
%dir /opt/aws/aws-opentelemetry-collector/var
/opt/aws/aws-opentelemetry-collector/bin/aoc
/opt/aws/aws-opentelemetry-collector/bin/VERSION
/opt/aws/aws-opentelemetry-collector/LICENSE
#/etc/init/amazon-cloudwatch-agent.conf
#/etc/systemd/system/amazon-cloudwatch-agent.service
#
#/usr/bin/aoc
#/etc/amazon/aws-opentelemetry-collector
#/var/log/amazon/aws-opentelemetry-collector
#/var/run/amazon/aws-opentelemetry-collector
