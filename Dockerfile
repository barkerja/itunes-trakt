FROM ubuntu:18.04

WORKDIR /app

RUN apt-get update && apt-get install -y curl jq nodejs npm
RUN npm install plist@3.0.1

COPY . .

ENTRYPOINT [ "./entrypoint.sh" ]
