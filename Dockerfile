FROM node:9
WORKDIR /app

RUN npm install -g contentful-cli

COPY ./app/package.json .
RUN npm install

COPY ./app .

USER node
EXPOSE 3000
CMD ["npm", "run", "start:dev"]
