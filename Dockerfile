FROM lacquerlabs/service-php7

RUN apk --update --no-cache add php7-mysqli openssl

COPY ./code .
