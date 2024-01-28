FROM node:lts-alpine3.19

WORKDIR /usr/src/app

COPY simple-webapp/package*.json ./

RUN npm install

COPY . .

ARG PORT=8080
EXPOSE ${PORT}

ENV PGHOST=${PGHOST}
ENV PGUSER=${PGUSER}
ENV PGPASSWORD=${PGPASSWORD}
ENV PGDATABASE=${PGDATABASE}
ENV PGPORT=${PGPORT}

CMD [ "node", "server.js" ]