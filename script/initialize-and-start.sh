#!/usr/bin/env bash

rake db:create
rake db:migrate

rails s
