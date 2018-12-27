#!/bin/bash

set -ex

CACHEDIR="/var/cache/trakt"
mkdir -p "$CACHEDIR"

trakt_curl() {
  PATH="$1"
  shift
  /usr/bin/curl --silent --fail \
       --header "Content-Type: application/json" \
       --header "Authorization: Bearer $ACCESS_TOKEN" \
       --header "trakt-api-version: 2" \
       --header "trakt-api-key: $CLIENT_ID" \
       "https://api.trakt.tv$PATH" "$@"
}

trakt_sync_collection() {
  trakt_curl "/sync/collection" --data-binary "@-" | jq
}

trakt_search() {
  TITLE="$1"
  YEAR="$2"
  CACHE="$CACHEDIR/$YEAR-$TITLE"

  if [ ! -f "$CACHE" ]; then
    ./trakt-search.sh "$TITLE" "$YEAR" > "$CACHE~"
    mv "$CACHE~" "$CACHE"
  fi

  cat "$CACHE"
}

map_track_to_trakt() {
  while IFS=$'\t' read -r name year date; do
    IDS=$(trakt_search "$name" "$year" | jq ".ids")
    if [[ "$IDS" != "null" ]]; then
      jq --null-input --argjson ids "$IDS" --argjson year "$year" --arg date "$date" '{ids: $ids, year: $year, collected_at: $date, media_type: "digital"}'
    fi
  done
}

sync() {
  plist-cli -d | \
    jq --raw-output '.Tracks | map(select(.Movie == true)) | .[] | [.Name, .Year, .["Date Added"]] | @tsv' | \
    map_track_to_trakt | \
    jq --slurp "{movies: .}" | \
    trakt_sync_collection
}

cat "$1" | sync
