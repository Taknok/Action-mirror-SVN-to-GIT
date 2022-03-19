FROM debian:11

WORKDIR /github/workspace

COPY entrypoint.sh /entrypoint.sh

RUN chmod u+x /entrypoint.sh && apt-get update && apt-get install -y svn2git procps

ENTRYPOINT ["/entrypoint.sh"]
