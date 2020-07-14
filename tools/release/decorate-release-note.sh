#! /bin/bash

WORKDIR=tools/release

RELEASE_NOTE_PATH="$1"
export S3_LINKS="$2"
export IMAGE_LINKS="$3"

echo ${S3_LINKS}
echo ${IMAGE_LINKS}

perl -i -pe 's/__s3-links__/$ENV{"S3_LINKS"}/g' ${RELEASE_NOTE_PATH}

perl -i -pe 's/__image-link__/$ENV{"IMAGE_LINKS"}/g' ${RELEASE_NOTE_PATH}
