FROM ruby:3.0.0-slim AS build-env

LABEL version='1.0'
LABEL maintainer='<cot@cmdm.csie.ntu.edu.tw>'

ARG APP_ROOT=/usr/local/app
ARG BUILD_PACKAGES="build-base curl-dev git"
ARG DEV_PACKAGES="mariadb-dev yaml-dev zlib-dev nodejs yarn"
ARG RUBY_PACKAGES="tzdata"

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    libmariadbclient-dev &&\
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y nodejs yarn

ENV LC_ALL C.UTF-8
ENV TZ Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

ADD ./src/Gemfile $APP_ROOT/Gemfile
#ADD ./src/Gemfile.lock $APP_ROOT/Gemfile.lock
#COPY ./src/package.json $APP_ROOT
COPY ./src/yarn.lock $APP_ROOT/

RUN bundle install --jobs 20 --retry 5
RUN yarn upgrade webpack@^4.0.0 \
    yarn install
COPY ./src/ $APP_ROOT
CMD rails tmp:cache:clear
CMD rails db:migrate assets:precompile

EXPOSE 3002
