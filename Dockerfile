# Build stage (Node 24+; aligns with package.json engines and jsdom 29 / Cypress)
FROM node:24-alpine AS build

ENV NPM_CONFIG_UPDATE_NOTIFIER=false

WORKDIR /app

COPY package*.json .npmrc ./

ARG VITE_IDP_LOGIN_URI=http://127.0.0.1:8080/login.html
ENV VITE_IDP_LOGIN_URI=$VITE_IDP_LOGIN_URI

# CodeArtifact auth via BuildKit secret (CI or scripts/docker-build.sh); no git clone of spa_utils.
RUN --mount=type=secret,id=codeartifact_token \
    --mount=type=cache,target=/root/.npm \
    sh -c 'echo "//mentor-forge-560167829275.d.codeartifact.us-east-1.amazonaws.com/npm/mentorhub-npm/:_authToken=$(cat /run/secrets/codeartifact_token)" >> .npmrc && \
    if [ -f package-lock.json ]; then npm ci; else npm install; fi'

COPY . .
RUN --mount=type=cache,target=/app/node_modules/.vite \
    npm run build

RUN DATE=$(date "+%Y-%m-%d:%H:%M:%S") && echo "$DATE" > ./dist/patch.txt

# Deploy stage
FROM nginx:stable-alpine

LABEL org.opencontainers.image.source="{{org.git_host}}/{{org.git_org}}/{{info.slug}}_{{service.name}}_spa"

ENV API_HOST={{info.slug}}_{{service.name}}_api
ENV API_PORT={{repo.port - 1}}

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf.template /etc/nginx/nginx.conf.template

RUN apk add --no-cache gettext

EXPOSE 80

CMD sh -c "envsubst '\${API_HOST} \${API_PORT}' < /etc/nginx/nginx.conf.template > /tmp/nginx.conf && exec nginx -g 'daemon off;' -c /tmp/nginx.conf"
