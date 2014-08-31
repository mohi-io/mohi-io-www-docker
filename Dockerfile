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


RUN cp -Rp "mohi-io-www/dist" "/var/www"

ADD nginx.conf /etc/nginx.conf

# clean up
RUN apt-get clean \
		&& apt-get autoclean -y \
		&& apt-get autoremove -y \
		ca-certificates \
    git \
    curl \
    && rm -rf mohi-io-www

# docker build --rm=true -t mohi-io-www .
# docker run --name mohi-io-www-nginx -d -p 8080:80 mohi-io-www


EXPOSE 80