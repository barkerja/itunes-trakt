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
  QUERY=$(echo $1 | sed -e "s/[^a-zA-Z0-9 ']//g")
  YEAR="$2"
  CACHE="$CACHEDIR/$YEAR-$QUERY"

  if [ ! -f "$CACHE" ]; then
    CURL_RESULT=$(trakt_curl "/search/movie" --get --data-urlencode "fields=title" --data-urlencode "query=$QUERY")
    echo "$CURL_RESULT" | jq --argjson year "$YEAR" \
      'map(select(.score > 900 and (.movie.year == $year-1 or .movie.year == $year or .movie.year == $year+1))) | first | .movie' > "$CACHE~"
    mv "$CACHE~" "$CACHE"
  fi

  RESULT=$(cat "$CACHE")
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
  node ./index.js "$1" | \
    jq --raw-output '[.Name, .Year, .["Date Added"]] | @tsv' | \
    map_track_to_trakt | \
    jq --slurp "{movies: .}" | \
    trakt_sync_collection
}

sync "$1"
