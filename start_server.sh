#!/usr/bin/env bash

echo "Waiting for PostgreSQL to launch on 5432..."
while ! nc -z postgres 5432; do
  sleep 0.1
done
echo "PostgreSQL launched"

rm -rf /opt/sabre/tmp/pids/server.pi*
bundle exec rake db:create &> /dev/null && echo "Database created" || echo "Database already exists"
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
