# Container image that runs your code
FROM ruby:3.0-alpine

RUN mkdir /gem 

COPY . /gem

RUN cd /gem

RUN bundle install

RUN chmod +x entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/gem/entrypoint.sh"]