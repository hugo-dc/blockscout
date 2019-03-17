FROM ubuntu

# Use bash instead of sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV NODE_VERSION 10.5.0
ENV PATH /opt/elixir/bin:$PATH
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisites
RUN apt-get update -y && apt-get install -y wget unzip curl make g++ python postgresql-10 automake libtool inotify-tools gcc libgmp3-dev sudo git
RUN apt-get install -y --no-install-recommends locales

# latin1 is default, elixir requires utf-8
RUN export LANG=en_US.UTF-8 \
    && echo $LANG UTF-8 > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=$LANG

RUN wget http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_21.0.5-1~ubuntu~artful_amd64.deb
RUN apt install -y ./esl-erlang_21.0.5-1~ubuntu~artful_amd64.deb

RUN wget https://github.com/elixir-lang/elixir/releases/download/v1.7.2/Precompiled.zip
RUN mkdir -p /opt/elixir
RUN unzip Precompiled.zip -d /opt/elixir

# Install node using nvm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
RUN . ~/.nvm/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

RUN pwd

RUN sudo echo 127.0.0.1 localhost blockscout blockscout.local >> /etc/hosts &&\
    sudo echo 255.255.255.255 broadcasthost >> /etc/hosts &&\
    sudo echo ::1 localhost blockscout blockscout.local >> /etc/hosts &&\
    sudo cat /etc/hosts

EXPOSE 5432

COPY ./  /blockscout

WORKDIR /blockscout

RUN pwd
RUN ls

RUN . ~/.nvm/nvm.sh &&\
    cd apps/block_scout_web/assets && npm install; cd - ; \
    cd apps/explorer && npm install; cd -

RUN mix local.hex --force
RUN mix do deps.get, local.rebar --force, deps.compile, compile

EXPOSE 4000
EXPOSE 4001

ENTRYPOINT ["/blockscout/run.sh"]
