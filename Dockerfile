FROM arm64v8/ruby:3.1.3-alpine

RUN apk --update add build-base tzdata postgresql-dev postgresql-client

ARG image_user=dry_user
ARG app_path=/usr/src/app

RUN adduser -D ${image_user}
USER ${image_user}

WORKDIR ${app_path}

COPY --chown=${image_user} Gemfile Gemfile.lock ./

RUN bundle install

COPY . .
