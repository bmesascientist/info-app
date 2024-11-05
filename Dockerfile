FROM node:lts-alpine

WORKDIR /usr/src/app

COPY info-app/package.json ./

RUN npm install

COPY info-app/. .

ENV NAMESPACE=""
ENV POD_NAME=""
ENV POD_IP=""
ENV NODE_NAME=""
ENV NODE_IP=""

EXPOSE 3000

CMD [ "node", "index.js" ]
