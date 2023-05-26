# Container image that runs your code
FROM ruby:3.0-alpine

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY action_stuff/entrypoint.sh /entrypoint.sh

RUN chmod +x entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]