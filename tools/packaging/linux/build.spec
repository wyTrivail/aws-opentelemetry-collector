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
cp -fa * ${RPM_BUILD_ROOT}

%files
%dir /opt/aws
%dir /opt/aws/aws-opentelemetry-collector
%dir /opt/aws/aws-opentelemetry-collector/bin
%dir /opt/aws/aws-opentelemetry-collector/doc
%dir /opt/aws/aws-opentelemetry-collector/etc
%dir /opt/aws/aws-opentelemetry-collector/logs
%dir /opt/aws/aws-opentelemetry-collector/var
/opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector
/opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector-ctl
/opt/aws/aws-opentelemetry-collector/bin/VERSION
/opt/aws/aws-opentelemetry-collector/LICENSE
/opt/aws/aws-opentelemetry-collector/etc/config.yaml
/opt/aws/aws-opentelemetry-collector/etc/.env
/etc/init/aws-opentelemetry-collector.conf
/etc/systemd/system/aws-opentelemetry-collector.service
/usr/bin/aws-opentelemetry-collector-ctl
#
#/usr/bin/aws-opentelemetry-collector
#/etc/amazon/aws-opentelemetry-collector
#/var/log/amazon/aws-opentelemetry-collector
#/var/run/amazon/aws-opentelemetry-collector

%pre
# Stop the agent before upgrades.
if [ $1 -ge 2 ]; then
    if [ -x /opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector-ctl ]; then
        /opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector-ctl -a stop
    fi
fi

if ! grep "^aoc:" /etc/group >/dev/null 2>&1; then
    groupadd -r aoc >/dev/null 2>&1
    echo "create group aoc, result: $?"
fi

if ! id aoc >/dev/null 2>&1; then
    useradd -r -M aoc -d /home/aoc -g aoc >/dev/null 2>&1
    echo "create user aoc, result: $?"
fi

%clean
rm -rf ${RPM_BUILD_ROOT}
