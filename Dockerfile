FROM debian:11

WORKDIR /github/workspace

COPY entrypoint.sh /entrypoint.sh

RUN chmod u+x /entrypoint.sh && apt-get update && apt-get install -y git-svn ruby procps

RUN git clone https://github.com/Taknok/svn2git.git && git checkout dev

RUN cd svn2git && gem build svn2git.gemspec -o svn2git.gem && gem install svn2git.gem

ENTRYPOINT ["/entrypoint.sh"]
