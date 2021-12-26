FROM debian:11

WORKDIR /github/workspace

COPY entrypoint.sh /entrypoint.sh

RUN chmod u+x /entrypoint.sh && apt-get update && apt-get install -y git-svn ruby

RUN gem install svn2git && \
  git config --global gc.auto 0 && \
  git config --global user.name "github-actions[bot]" && \
  git config --global user.email "4815162342+github-actions[bot]@users.noreply.github.com"

RUN whoami && echo "--------" && echo $HOME && echo "-----------" && git config -l --show-origin

ENTRYPOINT ["/entrypoint.sh"]
