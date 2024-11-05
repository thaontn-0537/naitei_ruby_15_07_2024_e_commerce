FROM ruby:3.2.2

RUN apt-get update -qq && apt-get install -y nodejs npm imagemagick redis-tools libvips42
RUN npm install --global yarn

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
    build-essential \
    gnupg2 \
    less \
    git \
    telnet \
    cron \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update -qq && apt-get install -y default-libmysqlclient-dev
RUN gem update --system && gem install bundler

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

COPY . ./

RUN bundle exec whenever --update-crontab

EXPOSE 3000

RUN touch /var/log/cron.log

CMD cron && rails server -b 0.0.0.0
