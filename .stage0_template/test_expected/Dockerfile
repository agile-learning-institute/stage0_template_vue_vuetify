# Build stage
FROM node:20-alpine AS build

WORKDIR /app

COPY package.json .npmrc ./

# GitHub npm registry requires a token even for public packages (not registry.npmjs.org). see README.
ARG NODE_AUTH_TOKEN
# Leading \n so append is a new line if .npmrc has no trailing newline (else URL + //auth breaks npm).
RUN if [ -n "$NODE_AUTH_TOKEN" ]; then \
      printf '\n//npm.pkg.github.com/:_authToken=%s\n' "$NODE_AUTH_TOKEN" >> .npmrc; \
    fi && npm install

COPY . .
RUN npm run build

RUN DATE=$(date "+%Y-%m-%d:%H:%M:%S") && echo "$DATE" > ./dist/patch.txt

# Deploy stage
FROM nginx:stable-alpine

LABEL org.opencontainers.image.source="https://github.com/agile-learning-institute/mentorhub_sample_spa"

ENV API_HOST=mentorhub_sample_api
ENV API_PORT=8389

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf.template /etc/nginx/nginx.conf.template

# envsubst for runtime nginx config (API_HOST/API_PORT in proxy_pass)
RUN apk add --no-cache gettext

EXPOSE 80

# Note: \${API_HOST} \${API_PORT} must be escaped so the shell passes them literally to envsubst
CMD sh -c "envsubst '\${API_HOST} \${API_PORT}' < /etc/nginx/nginx.conf.template > /tmp/nginx.conf && exec nginx -g 'daemon off;' -c /tmp/nginx.conf"
