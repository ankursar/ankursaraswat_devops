FROM node:10
WORKDIR /usr/app

COPY src/*.json ./
COPY src/server.js ./
RUN npm install
EXPOSE 3000
CMD [ "node", "server.js" ]
