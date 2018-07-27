FROM lacquerlabs/service-php7

RUN apk --update --no-cache add php7-mysqli php7-imagick openssl

COPY ./code .
