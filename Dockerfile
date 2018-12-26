FROM node:11.5

WORKDIR /app

RUN apt-get update && apt-get install -y curl jq

RUN npm install plist@3.0.1

COPY . .

ENTRYPOINT [ "./entrypoint.sh" ]
