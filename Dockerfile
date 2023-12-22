FROM ubuntu:latest
LABEL authors="adevireddy"

WORKDIR /app
COPY . /app
RUN bundle install

ENV HTTP_PORT 4567
ENV HTTP_HOST 0.0.0.0

EXPOSE $HTTP_PORT
CMD ["bundle", "exec", "rackup", "--host ${HTTP_HOST}", "-p ${HTTP_PORT}"]
