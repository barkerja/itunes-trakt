#!/bin/bash

set -ex

TITLE="$1"
YEAR="$2"

if [ -n "$YEAR" ]; then
  TITLE=$(echo "$TITLE" | sed "s/$YEAR//g")
fi
TITLE=$(echo "$TITLE" | sed -e "s/(.*)//g" | sed -e "s/[^a-zA-Z0-9:'. ]//g" | sed -e "s/ *$//")

if [ -z "$TITLE" ]; then
  echo "missing title" >&2
  exit 1
fi

trakt_search() {
  /usr/bin/curl --silent --fail \
       --header "Content-Type: application/json" \
       --header "trakt-api-version: 2" \
       --header "trakt-api-key: $CLIENT_ID" \
       --get https://api.trakt.tv/search/movie \
       --data-urlencode "fields=title" \
       --data-urlencode "query=$1"
}

filter_year() {
  if [ -n "$1" ]; then
    jq --argjson year "$1" 'select(.movie.year == $year-1 or .movie.year == $year or .movie.year == $year+1)'
  else
    cat
  fi
}

filter_score() {
  jq --argjson score "$1" 'select(.score > $score)'
}

trakt_search "$TITLE" | \
  # tee >(jq 1>&2) | \
  jq '.[]' | \
  filter_year "$YEAR" | \
  filter_score 900 | \
  jq --slurp 'first | .movie'
