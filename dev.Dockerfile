FROM ruby:2.7.2-alpine
#FROM alpine:3.7
MAINTAINER Catarse <contato@catarse.me>

ENV BUILD_PACKAGES postgresql-dev libxml2-dev libxslt-dev imagemagick imagemagick-dev openssl libpq libffi-dev bash curl-dev libstdc++ tzdata bash ca-certificates build-base ruby-dev libc-dev linux-headers postgresql-client postgresql git
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler ruby-irb ruby-bigdecimal ruby-json zlib-dev yaml-dev readline-dev ruby-dev ncurses
## Update and install all of the required packages.
## At the end, remove the apk cache
RUN apk update && \
    apk upgrade && \
    apk --update add --virtual build_deps $BUILD_PACKAGES && \
    apk --update add $RUBY_PACKAGES
#
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.10/main/ nodejs=12.18.4-r0
RUN apk add yarn=1.22.4-r0

RUN node -v
RUN mkdir /usr/app
WORKDIR /usr/app
#
RUN gem install bundler:2.1.4
#
COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
#
RUN bundle install

COPY . /usr/app
RUN yarn install

#
#RUN cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && echo "America/Sao_Paulo" >  /etc/timezone
#
## ==================================================================================================
## 7: Copy the rest of the application code, install nodejs as a build dependency, then compile the
## app assets, and finally change the owner of the code to 'nobody':
RUN set -ex \
  && mkdir -p /usr/app/tmp/cache \
  && mkdir -p /usr/app/tmp/pids \
  && mkdir -p /usr/app/tmp/sockets
  #  && chown -R nobody /usr/app
#
## ==================================================================================================
## 8: Set the container user to 'nobody':
# USER nobody
