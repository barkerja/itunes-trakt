FROM node:11.5

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY . .

ENTRYPOINT [ "node", "./index.js" ]
