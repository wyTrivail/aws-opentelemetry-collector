#! /bin/bash

VERSION=$1

sed "s/__VERSION__/$VERSION/g" tools/release/downloading-links.md.template > downloading-links

cat docs/releases/${VERSION}.md downloading-links > release-note
