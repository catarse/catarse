#!/usr/bin/env bash

echo "Entering catarse.js folder"
cd catarse.js

echo 'Installing catarse.js dev dependencies'
yarn install --production=false

if [ "$NODE_ENV" = "production" ] || [ "$RAILS_ENV" = "sandbox" ] || [ "$RAILS_ENV" = "production" ]; then
  echo 'Building catarse.js for production/sandbox'
  yarn run build:prod
else
  echo 'Building catarse.js for development/test'
  yarn run build
fi
