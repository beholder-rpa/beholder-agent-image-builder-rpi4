FROM node:latest as build

ENV WPA_SSID=
ENV WPA_PASSPHRASE=
ENV RPI_HOSTNAME=
ENV RPI_TIMEZONE=

WORKDIR /build
COPY package.json yarn.lock ./

# Install native dependencies and build
ENV NODE_ENV=production
RUN yarn --frozen-lockfile && yarn cache clean

COPY . .

# multistage
FROM node:slim as image
WORKDIR /create
COPY --from=build /build .

VOLUME /create/images

ENTRYPOINT ["./entrypoint.sh"]