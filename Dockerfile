FROM ruby:2.5

# Set local timezone
RUN apt-get update -qq 

RUN apt-get install tzdata && \
    cp /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    echo "Europe/Paris" > /etc/timezone

RUN apt-get install -y build-essential libpq-dev nodejs

# mapping of the user
ARG UID=1000
ARG GID=1000
ARG HOME=/app

RUN groupadd --gid $GID rubyapp -f \
&& useradd --uid $UID --gid $GID --shell /bin/bash --create-home --home $HOME rubyapp

# extract bundled gems into a data container
# in order to speed up the build time
ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle

RUN mkdir -p $BUNDLE_PATH && chown $UID:$GID $BUNDLE_PATH -R

# prepare entrypoint and wait-for-it script
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
COPY ./wait-for-it.sh /
RUN chmod +x /wait-for-it.sh

USER rubyapp

# install bundler
RUN gem install bundler

WORKDIR $HOME

# Gemfile.lock and Gemfile must exist
COPY --chown=rubyapp:rubyapp Gemfile $HOME/Gemfile
COPY --chown=rubyapp:rubyapp Gemfile.lock $HOME/Gemfile.lock

# add binaries to path
ENV PATH="${PATH}:${BUNDLE_BIN}"

# copy our app
COPY --chown=rubyapp:rubyapp . $HOME

ENTRYPOINT ["/docker-entrypoint.sh"]