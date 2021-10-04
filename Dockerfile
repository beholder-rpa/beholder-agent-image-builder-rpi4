FROM node:latest as build

WORKDIR /build
COPY package.json yarn.lock ./

# Install native dependencies and build
ENV NODE_ENV=production
RUN yarn --frozen-lockfile && yarn cache clean

COPY . .

# multistage
FROM node:slim as image

RUN apt-get update && apt-get install -y git

WORKDIR /create
COPY --from=build /build .

VOLUME /create/images

ENTRYPOINT "./entrypoint.sh" "${WPA_SSID}" "${WPA_PASSPHRASE}" "${RPI_HOSTNAME}" "${RPI_TIMEZONE}" "${BEHOLDER_MODE}"