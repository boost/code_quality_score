# Container image that runs your code
FROM ruby:3.0-alpine

RUN apk add git

RUN mkdir /gem && mkdir /app

COPY ./action_stuff /gem

WORKDIR "/gem"

RUN bundle install
RUN bundle binstubs code_quality_score

RUN chmod +x entrypoint.sh

WORKDIR "/app"

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/gem/entrypoint.sh"]