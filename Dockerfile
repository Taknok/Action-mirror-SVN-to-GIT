FROM debian:11

WORKDIR /github/workspace

RUN apt-get update && apt-get install -y git-svn ruby

RUN gem install svn2git && \
  git config --global gc.auto 0 && \
  git config --global user.name "github-actions[bot]" && \
  git config --global user.email "4815162342+github-actions[bot]@users.noreply.github.com"

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
