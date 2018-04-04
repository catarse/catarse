FROM kurenn/nodejsruby:0.0.1
MAINTAINER Abraham Kuri <kurenn@icalialabs.com>

ENV PATH=/usr/src/app/bin:$PATH RAILS_ENV=production RACK_ENV=production LANG=C.UTF-8
WORKDIR /usr/src/app

ADD ./Gemfile* /usr/src/app/


# Clean up un-needed files:
RUN rm -rf .dockerignore Dockerfile tmp/cache/* tmp/pids/* log/* dev-entrypoint docker-compose.yml *.env .env examples deploy/*

# Run dependencies install commands
RUN bundle install --deployment --without development test

ADD . /usr/src/app

# Precompile assets for production
RUN DB_ADAPTER=nulldb \
    DATABASE_URL=nulldb://localhost/nulldb?pool=5 \
    bundle exec rake assets:precompile RAILS_GROUPS=assets \
    && chown -R nobody /usr/src/app

EXPOSE 3000
