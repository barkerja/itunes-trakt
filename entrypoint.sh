#!/bin/bash

set -ex

trakt_curl() {
  PATH="$1"
  shift
  /usr/bin/curl --silent --fail \
       --header "Content-Type: application/json" \
       --header "Authorization: Bearer $ACCESS_TOKEN" \
       --header "trakt-api-version: 2" \
       --header "trakt-api-key: $CLIENT_ID" \
       "https://api.trakt.tv$PATH" $@
}

trakt_sync_collection() {
  trakt_curl "/sync/collection" --request POST --data-binary "@-" | jq
}

node ./index.js "$1" | trakt_sync_collection
