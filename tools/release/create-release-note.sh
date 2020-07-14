#! /bin/bash

WORKDIR=tools/release

export S3_LINKS="$1"
export IMAGE_LINKS="$2"

echo ${S3_LINKS}
echo ${IMAGE_LINKS}

cp $WORKDIR/release-note-template.yml .github/release-drafter.yml

perl -i -pe 's/__s3-links__/$ENV{"S3_LINKS"}/g' .github/release-drafter.yml

perl -i -pe 's/__image-link__/$ENV{"IMAGE_LINKS"}/g' .github/release-drafter.yml
