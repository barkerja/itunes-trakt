FROM ubuntu:18.04

WORKDIR /app

RUN apt-get update && apt-get install -y curl jq nodejs npm
RUN npm install -g plist-cli@1.1.0

COPY . .

ENTRYPOINT [ "./entrypoint.sh" ]
