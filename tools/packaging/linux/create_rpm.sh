#!/usr/bin/env bash

set -e
echo "*************************************************"
echo "Creating rpm file for Amazon Linux and RHEL, Arch: ${ARCH}"
echo "*************************************************"

SPEC_FILE="tools/packaging/linux/build.spec"
BUILD_ROOT="`pwd`/build/rpmbuild"
WORK_DIR="`pwd`/build/rpmtar"
VERSION=`cat VERSION`
RPM_NAME=aws-opentelemetry-collector
AOC_ROOT=${WORK_DIR}/${RPM_NAME}-${VERSION}

echo "Creating rpmbuild workspace"
mkdir -p ${BUILD_ROOT}/{RPMS,SRPMS,BUILD,SOURCES,SPECS}

echo "Creating file structure"
mkdir -p ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/logs
mkdir -p ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin
mkdir -p ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/etc
mkdir -p ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/var
mkdir -p ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/doc
mkdir -p ${AOC_ROOT}/etc/init
mkdir -p ${AOC_ROOT}/etc/systemd/system
mkdir -p ${AOC_ROOT}/usr/bin
mkdir -p ${AOC_ROOT}/etc/amazon
mkdir -p ${AOC_ROOT}/var/log/amazon
mkdir -p ${AOC_ROOT}/var/run/amazon

echo "Copying application files"
# License, version, release note... 
cp LICENSE ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/
cp VERSION ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin/
cp docs/releases/${VERSION}.md ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/RELEASE_NOTE

# binary
cp build/linux/aoc_linux_${ARCH} ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector
# ctl
cp tools/ctl/linux/aws-opentelemetry-collector-ctl ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin/
# default config
cp config.yaml ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/etc
# .env
cp .env ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/etc
# service config
cp tools/packaging/linux/aws-opentelemetry-collector.service ${AOC_ROOT}/etc/systemd/system/
cp tools/packaging/linux/aws-opentelemetry-collector.conf ${AOC_ROOT}/etc/init/

echo "assign permission to the files"
chmod ug+rx ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector
chmod ug+rx ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector-ctl
chmod ug+rx ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/etc/config.yaml
chmod ug+rx ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/etc/.env

echo "create symlinks"
ln -f -s /opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector-ctl ${AOC_ROOT}/usr/bin/aws-opentelemetry-collector-ctl
ln -f -s /opt/aws/aws-opentelemetry-collector/etc ${AOC_ROOT}/etc/amazon/aws-opentelemetry-collector
ln -f -s /opt/aws/aws-opentelemetry-collector/logs ${AOC_ROOT}/var/log/amazon/aws-opentelemetry-collector
ln -f -s /opt/aws/aws-opentelemetry-collector/var ${AOC_ROOT}/var/run/amazon/aws-opentelemetry-collector

echo "build source tarball"
tar -czvf ${RPM_NAME}-${VERSION}.tar.gz -C ${WORK_DIR} .
mv ${RPM_NAME}-${VERSION}.tar.gz ${BUILD_ROOT}/SOURCES/
rm -rf ${WORK_DIR}

echo "Creating the rpm package"
rpmbuild --define "VERSION $VERSION" --define "RPM_NAME $RPM_NAME" --define "_topdir ${BUILD_ROOT}" -bb -v --clean ${SPEC_FILE} --target ${ARCH}-linux

echo "Copy rpm file to ${DEST}"
mkdir -p ${DEST}
cp ${BUILD_ROOT}/RPMS/${ARCH}/${RPM_NAME}-${VERSION}-1.${ARCH}.rpm ${DEST}/${RPM_NAME}.rpm
