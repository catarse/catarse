FROM ruby:2.2.2

RUN mkdir -p /tmp/
COPY Gemfile* /tmp/

RUN apt-get update && apt-get -y install npm && apt-get clean
RUN cd /tmp/ && bundle install
RUN npm install -g bower
RUN bower install --allow-root
RUN apt-get update && apt-get -y install postgresql-client

WORKDIR /app/
