FROM node:11.5

WORKDIR /app

RUN apt-get update && apt-get install -y curl jq

COPY package.json package-lock.json ./
RUN npm install

COPY . .

ENTRYPOINT [ "./entrypoint.sh" ]
