FROM ruby:3.2
LABEL authors="adevireddy"

WORKDIR /app
COPY . /app
RUN bundle install
ENV REDIS="redis"

EXPOSE 8000
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "8000"]
