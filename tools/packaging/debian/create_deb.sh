#!/usr/bin/env bash
echo "****************************************"
echo "Creating deb file for Debian Linux ${ARCH}"
echo "****************************************"

BUILD_ROOT="`pwd`/build/linux/debian"
VERSION=`cat VERSION`
DEB_NAME=aws-opentelemetry-collector
AOC_ROOT=${BUILD_ROOT}

echo "BASE_ROOT: ${BUILD_ROOT}    agent_version: ${VERSION} AGENT_BIN_DIR_DEB: ${AOC_ROOT}"

echo "Creating debbuild workspace"
mkdir -p ${AOC_ROOT}

echo "Creating debian folders"

#BUILD_ROOT="${BRAZIL_BUILD_ROOT}/private/linux_${ARCH}/debian"
#AGENT_BIN_DIR_LINUX="${BRAZIL_BUILD_ROOT}/private/linux/${ARCH}/aws-opentelemetry-collector-pre-pkg"

mkdir -p ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/logs
mkdir -p ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin
mkdir -p ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/etc
mkdir -p ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/var
mkdir -p ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/doc
mkdir -p ${AOC_ROOT}/etc/init
mkdir -p ${AOC_ROOT}/etc/systemd/system/

mkdir -p ${AOC_ROOT}/bin

echo "Copying application files"
cp LICENSE ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/
cp VERSION ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin/

cp build/linux/aoc_linux_${TARGET_SUPPORTED_ARCH} ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector
cp tools/ctl/linux/aws-opentelemetry-collector-ctl ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin/
cp config.yaml ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/etc
cp .env ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/etc
cp tools/packaging/linux/aws-opentelemetry-collector.service ${AOC_ROOT}/etc/systemd/system/
cp tools/packaging/linux/aws-opentelemetry-collector.conf ${AOC_ROOT}/etc/init/


############################# create the symbolic links here to make them managed by dpkg
# bin
mkdir -p ${AOC_ROOT}/usr/bin
ln -f -s /opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector-ctl ${AOC_ROOT}/usr/bin/aws-opentelemetry-collector-ctl
# etc
mkdir -p ${AOC_ROOT}/etc/amazon
ln -f -s /opt/aws/aws-opentelemetry-collector/etc ${AOC_ROOT}/etc/amazon/aws-opentelemetry-collector
# log
mkdir -p ${AOC_ROOT}/var/log/amazon
ln -f -s /opt/aws/aws-opentelemetry-collector/logs ${AOC_ROOT}/var/log/amazon/aws-opentelemetry-collector
# pid
mkdir -p ${AOC_ROOT}/var/run/amazon
ln -f -s /opt/aws/aws-opentelemetry-collector/var ${AOC_ROOT}/var/run/amazon/aws-opentelemetry-collector


#cp ${BRAZIL_BUILD_ROOT}/Tools/src/LICENSE ${BUILD_ROOT}/bin/debian_${ARCH}/debian/usr/share/doc/aws-opentelemetry-collector/copyright
cp tools/packaging/debian/conffiles ${AOC_ROOT}/
cp tools/packaging/debian/preinst ${AOC_ROOT}/
cp tools/packaging/debian/prerm ${AOC_ROOT}/
cp tools/packaging/debian/debian-binary ${AOC_ROOT}/

chmod ug+rx ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector
chmod ug+rx ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/bin/aws-opentelemetry-collector-ctl
chmod ug+rx ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/etc/config.yaml
chmod ug+rx ${AOC_ROOT}/opt/aws/aws-opentelemetry-collector/etc/.env

echo "Constructing the control file"
echo 'Package: aws-opentelemetry-collector' > ${AOC_ROOT}/control
echo "Architecture: ${ARCH}" >> ${AOC_ROOT}/control
echo -n 'Version: ' >> ${AOC_ROOT}/control
echo -n ${VERSION} >> ${AOC_ROOT}/control
echo '-1' >> ${AOC_ROOT}/control
cat tools/packaging/debian/control >> ${BUILD_ROOT}/control

echo "Setting permissioning as required by debian"
cd ${AOC_ROOT}/..; find ./debian -type d | xargs chmod 755; cd ~-

# the below permissioning is required by debian
cd ${AOC_ROOT}; tar czf data.tar.gz opt etc usr var --owner=0 --group=0 ; cd ~-
cd ${AOC_ROOT}; tar czf control.tar.gz control conffiles preinst prerm --owner=0 --group=0 ; cd ~-

echo "Creating the debian package"
echo "Constructing the deb package"
ar r ${AOC_ROOT}/bin/aws-opentelemetry-collector-${ARCH}-${AGENT_VERSION}-1.deb ${AOC_ROOT}/debian-binary
ar r ${AOC_ROOT}/bin/aws-opentelemetry-collector-${ARCH}-${AGENT_VERSION}-1.deb ${AOC_ROOT}/control.tar.gz
ar r ${AOC_ROOT}/bin/aws-opentelemetry-collector-${ARCH}-${AGENT_VERSION}-1.deb ${AOC_ROOT}/data.tar.gz


echo "Copy debian file to ${DEST}"
mkdir -p ${DEST}
mv ${AOC_ROOT}/bin/aws-opentelemetry-collector-${ARCH}-${AGENT_VERSION}-1.deb ${DEST}/aws-opentelemetry-collector.deb

echo "remove working directory"
rm -rf ${AOC_ROOT}
