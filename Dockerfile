FROM nginx

RUN apt-get update && apt-get install -y \
		ca-certificates \
		git \
		curl

# verify gpg and sha256: http://nodejs.org/dist/v0.10.30/SHASUMS256.txt.asc
# gpg: aka "Timothy J Fontaine (Work) <tj.fontaine@joyent.com>"
RUN gpg --keyserver pgp.mit.edu --recv-keys 7937DFD2AB06298B2293C3187D33FF9D0246406D

ENV NODE_VERSION 0.10.30

# install nodejs
RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
	&& curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
	&& gpg --verify SHASUMS256.txt.asc \
	&& grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
	&& tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
	&& rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc


# prepare repository, bower and node modules
RUN git clone "https://github.com/mohi-io/mohi-io-www.git" \
	&& cd "mohi-io-www"  \
	&& npm install \
	&& npm install grunt-cli -g \
	&& npm install bower -g && bower install --allow-root \
  && grunt build

ADD build /usr/local/nginx/html/build

#RUN ls /usr/local/nginx/html
RUN ls "mohi-io-www"
RUN pwd
RUN ls
RUN ls "build"
RUN cp -Rp "mohi-io-www/dist/" "build/dist/"
RUN ls "build"
RUN ls "build/dist"

RUN sh -c "curl https://get.docker.io/gpg | apt-key add -" \
    && sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list" \
    && apt-get update \
    && apt-get install lxc-docker -y

RUN cd build && docker build -t mohi-io-www-img .
#RUN mv "mohi-io-www/dist" "/usr/local/nginx/html"
#RUN ls /usr/local/nginx/html

ADD nginx.conf /etc/nginx.conf

# clean up
RUN apt-get purge -y \
		ca-certificates \
		git \
		curl \
		&& apt-get clean \
		&& apt-get autoremove -y
#		&& rm -rf mohi-io-www

# docker build --rm=true -t mohi-io-www .
# docker run --name mohi-io-www-nginx -d -p 8080:80 mohi-io-www


EXPOSE 80