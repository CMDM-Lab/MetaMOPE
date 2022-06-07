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
    apt-get update && apt-get install -y nodejs yarn zip

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' && \
    add-apt-repository "deb http://cloud.r-project.org/bin/linux/debian $(lsb_release -cs)-cran40/" && \
    apt-get update && apt-get install -y \
    r-base \
    libnetcdf-dev \
    libcurl4-openssl-dev \
    libxml2-dev

RUN Rscript -e 'if (!require("BiocManager", quietly = TRUE)) install.packages("BiocManager")'
RUN Rscript -e 'BiocManager::install("xcms", dependencies=TRUE, lib="/usr/local/lib/R/site-library")'
RUN Rscript -e 'install.packages("baseline",dependencies=TRUE, repos="http://cran.rstudio.com/", lib="/usr/local/lib/R/site-library")'
RUN Rscript -e 'install.packages("prospectr",dependencies=TRUE, repos="http://cran.rstudio.com/", lib="/usr/local/lib/R/site-library")'

# Define build arguments
ARG USER_ID
ARG GROUP_ID

# Define environment variables
ENV USER_ID=$USER_ID
ENV GROUP_ID=$GROUP_ID
ENV USER_ID=${USER_ID:-1001}
ENV GROUP_ID=${GROUP_ID:-1001}

# Add group and user based on build arguments
RUN addgroup --gid ${GROUP_ID} myersccy
RUN adduser --disabled-password --gecos '' --uid ${USER_ID} --gid ${GROUP_ID} myersccy

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
#RUN yarn upgrade webpack@^4.0.0 \
#    yarn install
RUN yarn add webpack-dev-server@3.11.2 --exact
RUN yarn install
COPY ./src/ $APP_ROOT
CMD rails webpacker:install
CMD rails tmp:cache:clear
CMD rails db:migrate assets:precompile

RUN chown -R myersccy:myersccy /usr/local/app

EXPOSE 13002