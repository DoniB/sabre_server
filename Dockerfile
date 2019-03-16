FROM ruby:2.5.3

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client-9.6 netcat

WORKDIR /opt/sabre

ENV RAILS_ENV='production'
ENV RACK_ENV='production'

ADD ./Gemfile /opt/sabre/Gemfile
ADD ./Gemfile.lock /opt/sabre/Gemfile.lock

COPY ./ ./

RUN bundle install --jobs 20 --retry 5 --without development test 

EXPOSE  3000

CMD ["bash", "start_server.sh"]