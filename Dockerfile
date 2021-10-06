FROM node:latest as build

WORKDIR /build
COPY package.json yarn.lock ./

# Install native dependencies and build
ARG IMAGE_SUFFIX=armhf-lite
ENV NODE_ENV=production
RUN yarn --frozen-lockfile && yarn cache clean

COPY . .

# multistage
FROM node:slim as image

RUN apt-get update && apt-get install -y git

WORKDIR /create
COPY --from=build /build .

VOLUME /create/images

ENTRYPOINT "./entrypoint.sh" "${IMAGE_SUFFIX}" "${WPA_SSID}" "${WPA_PASSPHRASE}" "${RPI_HOSTNAME}" "${RPI_TIMEZONE}" "${BEHOLDER_MODE}"