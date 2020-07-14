#! /bin/bash

WORKDIR=tools/release

export CHANGE_LOG="$1"
export S3_LINKS="$2"
export IMAGE_LINKS="$3"

echo ${CHANGE_LOG}
echo ${S3_LINKS}
echo ${IMAGE_LINKS}

cp $WORKDIR/release-note.template release-note

perl -i -pe 's/__changes__/$ENV{"CHANGE_LOG"}/g' release-note

perl -i -pe 's/__s3-links__/$ENV{"S3_LINKS"}/g' release-note

perl -i -pe 's/__image-link__/$ENV{"IMAGE_LINKS"}/g' release-note
