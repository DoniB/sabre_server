#!/usr/bin/env bash
if [ "$RAILS_ENV" == "production" ]
then
    bundle exec rake db:migrate
    echo Starting production server...
    bundle exec puma -C config/puma.rb
else
    rm -rf /opt/sabre/tmp/pids/server.pi*
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
    echo Starting development server...
    bundle exec rails s -p 3000 -b 0.0.0.0
fi
