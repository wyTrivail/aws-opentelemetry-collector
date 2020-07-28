#! /bin/bash

# this is the command to send the dispatch event to the nightly-clean-artifact workflow
# please specify the TOKEN with the github token
# example of how to use it: TOKEN=e7*******************************3d0d ./clean-artifact.sh

OWNER=mxiamxia
REPO=aws-opentelemetry-collector

curl -u="${OWNER}:${TOKEN}" -X POST --data '{"event_type": "clean-artifacts"}' "https://api.github.com/repos/${OWNER}/${REPO}/dispatches"
