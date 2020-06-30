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
mkdir -p ${AOC_ROOT}/etc/systemd/system/

echo "Copying application files"
cp LICENSE ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/
cp VERSION ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin/
cp build/linux/aoc_linux_${ARCH} ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin/aoc
chmod ug+rx ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin/aoc

echo "build source tarball"
tar -czvf ${RPM_NAME}-${VERSION}.tar.gz -C ${WORK_DIR} .
mv ${RPM_NAME}-${VERSION}.tar.gz ${BUILD_ROOT}/SOURCES/
rm -rf ${WORK_DIR}

echo "Creating the rpm package"
rpmbuild --define "VERSION $VERSION" --define "RPM_NAME $RPM_NAME" --define "_topdir ${BUILD_ROOT}" -bb -v --clean ${SPEC_FILE} --target ${ARCH}

echo "Copy rpm file to ${DEST}"
mkdir -p ${DEST}
cp ${BUILD_ROOT}/RPMS/${ARCH}/${RPM_NAME}-${VERSION}-1.${ARCH}.rpm ${DEST}/${RPM_NAME}.rpm
