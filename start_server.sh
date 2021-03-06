#!/usr/bin/env bash

echo "Waiting for PostgreSQL to launch on 5432..."
while ! nc -z $SABRE_DATABASE_HOST 5432; do
  sleep 0.1
done
echo "PostgreSQL launched"

if [ "$RAILS_ENV" == "test" ]
then
    bundle install
fi

rm -rf /opt/sabre/tmp/pids/server.pi*

if [ "$JMETER" == "1" ]
then
    export RAILS_ENV=production
    export SABRE_DATABASE=sabre_jmeter
    export DISABLE_DATABASE_ENVIRONMENT_CHECK=1
    bundle exec rake db:drop
fi

bundle exec rake db:create &> /dev/null && echo "Database created" || echo "Database already exists"
bundle exec rake db:migrate

if [ "$RAILS_ENV" == "production" ]
then
    bundle exec rake db:seed
    echo Starting production server...
    bundle exec puma -C config/puma.rb
elif [ "$RAILS_ENV" == "test" ]
then
    bundle exec rspec
else
    bundle exec rake db:seed
    echo Starting development server...
    bundle exec rails s -p 3000 -b 0.0.0.0
fi
