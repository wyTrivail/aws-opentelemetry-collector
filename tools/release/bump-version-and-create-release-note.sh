#! /bin/bash

## this is the script to bump the version and create the release note
## please run this script whenever you want to bump the version instead of directly modifying the VERSION file
## below is an example to run this script: 
## RELEASE_VERSION=v0.1.8 GITHUB_USER=mxiamxia GITHUB_TOKEN=e75***********fa3d0d ./tools/release/bump-version-and-create-release-note.sh

# get the current version
VERSION=`cat VERSION`
OUTPUT="docs/releases/${RELEASE_VERSION}.md"

# generate release note
docker run -it -v "`pwd`":/usr/local/src/your-app ferrarimarco/github-changelog-generator \
       	--user ${GITHUB_USER} \
	--project aws-opentelemetry-collector \
	-t ${GITHUB_TOKEN} \
	--since-tag ${VERSION} \
	--future-release ${RELEASE_VERSION} \
	--output ${OUTPUT}

# bump the version
echo ${RELEASE_VERSION} > VERSION

# create a git commit
#git add VERSION ${OUTPUT}
#git commit -m "bump version to ${VERSION}, and create release note"
