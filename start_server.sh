#!/usr/bin/env bash

rm -rf /opt/sabre/tmp/pids/server.pi*
bundle exec rake db:create
bundle exec rake db:migrate

if [ "$RAILS_ENV" == "production" ]
then
    echo Starting production server...
    bundle exec puma -C config/puma.rb
else
    bundle exec rake db:seed
    echo Starting development server...
    bundle exec rails s -p 3000 -b 0.0.0.0
fi
