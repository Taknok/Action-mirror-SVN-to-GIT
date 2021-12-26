FROM debian:11

WORKDIR /github/workspace

COPY entrypoint.sh /entrypoint.sh

RUN chmod u+x /entrypoint.sh && apt-get update && apt-get install -y git-svn ruby

RUN gem install svn2git

ENTRYPOINT ["/entrypoint.sh"]
