# syntax=docker/dockerfile:experimental

ARG NODE_VERSION="12.13-alpine"
ARG NGINX_VERSION="1.16-alpine"

FROM node:${NODE_VERSION} AS builder

RUN apk add --no-cache python make g++

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . ./

RUN npm run ng build -- --prod --output-path=dist

FROM nginx:${NGINX_VERSION}

LABEL NODE_VERSION=$NODE_VERSION
LABEL NGINX_VERSION=$NGINX_VERSION

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

COPY nginx.conf /etc/nginx/conf.d/

COPY --from=builder /app/node_modules .
COPY --from=builder /app/dist /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]