FROM centos:7 AS build-env

LABEL  maintainer "katsumi kato <katzumi+github@gmail.com>"

ENV	RBENV_ROOT /usr/local/rbenv
ENV	APP_ROOT /web/camaleon_cms

COPY	rbenv.sh /etc/profile.d/

RUN	true && \
# DNS add.
	echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
# build tools install
	yum install -y git gcc make bzip2 tar gcc-c++ openssl-devel readline-devel zlib-devel mysql-devel && \
# rbenv install
	export RBENV_ROOT="/usr/local/rbenv" && \
	git clone git://github.com/rbenv/rbenv.git ${RBENV_ROOT} && \
	cd ${RBENV_ROOT} && src/configure && make -C src && \
	mkdir -p ${RBENV_ROOT}/plugins && \
	git clone https://github.com/rbenv/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build && \
	cd ${RBENV_ROOT}/plugins/ruby-build && \
	./install.sh && \
	source /etc/profile.d/rbenv.sh && \
# ruby install
	rbenv install -l && \
	rbenv install 2.4.1 && \
	rbenv rehash && \
	rbenv global 2.4.1 && \
# gem update
	echo "gem: --no-document" > ~/.gemrc && \
	rbenv exec gem update --system && \
# rails install
	rbenv exec gem install rails -v 5.1.2 && \
# Bundler install
	rbenv exec gem install bundler && \
	rbenv exec gem install therubyracer && \
	rbenv exec gem install mysql2 && \
	rbenv rehash && \
	true

RUN	true && \
	source /etc/profile.d/rbenv.sh && \
# app new
	mkdir -p ${APP_ROOT} && \
	cd ${APP_ROOT} && \
	rails new -d mysql . && \
        sed -i "s/^# gem 'therubyracer'/gem 'therubyracer'/g" Gemfile && \
	echo "gem 'camaleon_cms', github: 'owen2345/camaleon-cms'" >> Gemfile && \
	echo "gem 'draper', '~> 3'" >> Gemfile && \
	bundle update && \
	bundle install && \
# nginx connecting sockets
	echo "app_root = File.expand_path(\"../..\", __FILE__)" >> config/puma.rb && \
	echo "bind \"unix://#{app_root}/tmp/sockets/puma.sock\"" >> config/puma.rb && \
	true

FROM centos:7 AS rails_app

LABEL  maintainer "katsumi kato <katzumi+github@gmail.com>"

ENV	RBENV_ROOT /usr/local/rbenv
ENV	APP_ROOT /web/camaleon_cms

COPY --from=build-env $RBENV_ROOT $RBENV_ROOT
COPY --from=build-env $APP_ROOT $APP_ROOT

COPY	rbenv.sh /etc/profile.d/
COPY	config/database.yml $APP_ROOT/config/database.yml

RUN     true && \
# DNS add.
	echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
# shared library install
	yum -y install mysql ImageMagick && \
        source /etc/profile.d/rbenv.sh && \
	cd ${APP_ROOT} && \
        rails generate camaleon_cms:install && \
# clean
	yum clean all && \
        true

# Expose volumes to nginx
VOLUME [ "$APP_ROOT/public", "$APP_ROOT/tmp/sockets" ]

COPY	entrypoint.sh /

ENTRYPOINT	[ "/entrypoint.sh" ]

EXPOSE	3000
