FROM ruby:2.4.4-alpine
#FROM alpine:3.7
MAINTAINER Catarse <contato@catarse.me>

ENV BUILD_PACKAGES postgresql-dev libxml2-dev libxslt-dev imagemagick imagemagick-dev openssl libpq libffi-dev bash curl-dev libstdc++ tzdata bash ca-certificates build-base ruby-dev libc-dev linux-headers postgresql-client postgresql git
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler ruby-irb ruby-bigdecimal ruby-json nodejs nodejs-npm zlib-dev yaml-dev readline-dev ruby-dev ncurses
#
## Update and install all of the required packages.
## At the end, remove the apk cache
RUN apk update && \
    apk upgrade && \
    apk --update add --virtual build_deps $BUILD_PACKAGES && \
    apk --update add $RUBY_PACKAGES
#
RUN mkdir /usr/app
WORKDIR /usr/app
#
COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
#
RUN bundle install

COPY . /usr/app
RUN npm install

#
#RUN cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && echo "America/Sao_Paulo" >  /etc/timezone
#
## ==================================================================================================
## 7: Copy the rest of the application code, install nodejs as a build dependency, then compile the
## app assets, and finally change the owner of the code to 'nobody':
RUN set -ex \
  && mkdir -p /usr/app/tmp/cache \
  && mkdir -p /usr/app/tmp/pids \
  && mkdir -p /usr/app/tmp/sockets \
  && chown -R nobody /usr/app
#
## ==================================================================================================
## 8: Set the container user to 'nobody':
# USER nobody
