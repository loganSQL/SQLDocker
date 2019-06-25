# [Dockerizing a Node.js web app](https://nodejs.org/de/docs/guides/nodejs-docker-webapp/)
## Create the Node.js app
### package.json: to describe your app and its dependencies
```
{
  "name": "docker_web_app",
  "version": "1.0.0",
  "description": "Node.js on Docker",
  "author": "LoganSQL <logansql@example.com>",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.16.1"
  }
}
```

run 'npm install' to generate package-lock.json

### server.js: define a web app using Express.js framework
```
'use strict';

const express = require('express');

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
  res.send('Hello world\n');
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
```

### start the web app
```
node server.js

Running on http://0.0.0.0:8080
```

## Build a Docker image of your app.
### Dockerfile
```
# based on https://hub.docker.com/_/node
FROM node:8.9.3-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install
# If you are building your code for production
# RUN npm ci --only=production

# Bundle app source
COPY . .

EXPOSE 8080
CMD [ "npm", "start" ]
```
### .dockerignore
```
# prevent your local modules and debug logs from being copied onto your Docker image and possibly overwriting modules installed within your image.
node_modules
npm-debug.log
```
### Docker Image
```
# Build
docker build -t logansql/node-alphine .

# Run
docker run -p 55555:8080 -d --name test-node-alphine logansql/node-alphine

# Get container ID
$ docker ps

# Print app output
$ docker logs test-node-web-app

# Check it out
curl http://localhost:55555/
# brower
start http://localhost:55555/
# go inside
docker exec -it test-node-web-app /bin/bash
#
# the image from 'FROM node:8.9.3-alpine' is tiny 70MB, 
# default 'FROM node:8' is 897MB
#
docker images
REPOSITORY                            TAG                   IMAGE ID            CREATED             SIZE
logansql/node-alphine                 latest                49c4b7b2b458        14 seconds ago      70.1MB
logansql/node-web-app                 latest                fd5fa3252fa7        2 hours ago         897MB
```