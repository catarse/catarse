FROM ruby:2.3.1
MAINTAINER Abraham Kuri <kurenn@icalialabs.com>

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN set -ex \
  && curl -sL "https://deb.nodesource.com/setup_6.x" | bash - \
  && apt-get -y install nodejs \
  && npm install -g bower

RUN gem install bundler -v 1.11.2 --no-ri --no-rdoc

ENV PATH=/usr/src/app/bin:$PATH LANG=C.UTF-8

ADD Gemfile* /usr/src/app/

# Run dependencies install commands
RUN bundle
