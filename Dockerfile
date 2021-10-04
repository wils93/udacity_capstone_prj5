FROM node:16 as build

WORKDIR /app
COPY . .
RUN npm install \
    && npm run build

FROM nginx:1.21.3

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/public /usr/share/nginx/html
