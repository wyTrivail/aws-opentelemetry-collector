#! /bin/bash

WORKDIR=tools/release

export CHANGE_LOG=$1
export S3_LINKS=$2
export IMAGE_LINKS=$3

echo ${CHANGE_LOG}
echo ${S3_LINKS}
echo ${IMAGE_LINKS}

cp $WORKDIR/release-note.template release-note

perl -i -pe 's/{{changes}}/$ENV{"CHANGE_LOG"}/g' release-note

perl -i -pe 's/{{s3-links}}/$ENV{"S3_LINKS"}/g' release-note

perl -i -pe 's/{{image-link}}/$ENV{"IMAGE_LINKS"}/g' release-note
