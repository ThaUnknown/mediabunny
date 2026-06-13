FROM node:22-alpine
WORKDIR /app
COPY package.json package-lock.json ./
COPY packages/mp3-encoder/package.json packages/mp3-encoder/
COPY packages/ac3/package.json packages/ac3/
COPY packages/flac-encoder/package.json packages/flac-encoder/
COPY packages/aac-encoder/package.json packages/aac-encoder/
COPY packages/server/package.json packages/server/
RUN npm ci
COPY . .
RUN apk add --no-cache bash && npm run build
