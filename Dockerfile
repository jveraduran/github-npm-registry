FROM ghcr.io/jveraduran/github-container-registry@sha256:dbbfaa610555c4c21c4ef59ea97b32bdb8f610c25c61bfc13f913dab54627d08

COPY . .

WORKDIR /usr/src/app/

RUN npm version
