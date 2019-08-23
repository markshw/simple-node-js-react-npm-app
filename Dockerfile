FROM node:6-alpine

# install deps
ADD package.json /tmp/package.json
RUN cd /tmp && npm install

# Copy deps
RUN mkdir -p /opt/my-app && cp -a /tmp/node_modules /opt/my-app

# Setup workdir
WORKDIR /opt/my-app
COPY . /opt/my-app

# run
EXPOSE 3000
CMD ["npm", "start"]
