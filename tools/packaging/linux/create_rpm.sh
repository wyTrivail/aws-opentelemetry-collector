#!/usr/bin/env bash

set -e
echo "*************************************************"
echo "Creating rpm file for Amazon Linux and RHEL, Arch: ${ARCH}"
echo "*************************************************"

SPEC_FILE="tools/packaging/linux/build.spec"
BUILD_ROOT="`pwd`/build/rpmbuild"
WORK_DIR="`pwd`/build/rpmtar"
VERSION=`cat VERSION`

echo "Creating rpmbuild workspace"
mkdir -p ${BUILD_ROOT}/{RPMS,SRPMS,BUILD,SOURCES,SPECS}
mkdir -p ${WORK_DIR}/aoc-${VERSION}/opt/aws/aws-opentelemetry-collector/logs
mkdir -p ${WORK_DIR}/aoc-${VERSION}/opt/aws/aws-opentelemetry-collector/bin
mkdir -p ${WORK_DIR}/aoc-${VERSION}/opt/aws/aws-opentelemetry-collector/etc
mkdir -p ${WORK_DIR}/aoc-${VERSION}/opt/aws/aws-opentelemetry-collector/var
mkdir -p ${WORK_DIR}/aoc-${VERSION}/opt/aws/aws-opentelemetry-collector/doc
mkdir -p ${WORK_DIR}/aoc-${VERSION}/etc/init
mkdir -p ${WORK_DIR}/aoc-${VERSION}/etc/systemd/system/

echo "Copying application files"
cp LICENSE ${WORK_DIR}/aoc-${VERSION}/opt/aws/aws-opentelemetry-collector/
cp VERSION ${WORK_DIR}/aoc-${VERSION}/opt/aws/aws-opentelemetry-collector/bin/
cp build/linux/aoc_linux_${ARCH} ${WORK_DIR}/aoc-${VERSION}/opt/aws/aws-opentelemetry-collector/bin/aoc
chmod ug+rx ${WORK_DIR}/aoc-${VERSION}/opt/aws/aws-opentelemetry-collector/bin/aoc

echo "build source tarball"
tar -czvf aoc-${VERSION}.tar.gz -C ${WORK_DIR} .
mv aoc-${VERSION}.tar.gz ${BUILD_ROOT}/SOURCES/
rm -rf ${WORK_DIR}

echo "Creating the rpm package"
rpmbuild --define "VERSION $VERSION" --define "_topdir ${BUILD_ROOT}" -bb -v --clean ${SPEC_FILE} --target ${ARCH}

echo "Copy rpm file to ${DEST}"
mkdir -p ${DEST}
cp ${BUILD_ROOT}/RPMS/${ARCH}/aoc-${VERSION}-1.${ARCH}.rpm ${DEST}/aoc.rpm
