FROM nginx

ENV NGINX_VERSION 1.7.4
ENV NODE_VERSION 0.10.31

RUN apt-get update && apt-get install -y \
  ca-certificates \
  git \
  curl \
  && gpg --keyserver pgp.mit.edu --recv-keys 7937DFD2AB06298B2293C3187D33FF9D0246406D \
  && curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
	&& curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
	&& gpg --verify SHASUMS256.txt.asc \
	&& grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
	&& tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
	&& rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
  && git clone "https://github.com/mohi-io/mohi-io-www.git" \
	&& cd "mohi-io-www"  \
	&& npm install \
	&& npm install -g bower grunt-cli \
	&& bower install --allow-root \
  && grunt build \
  && cd .. \
  && cp -Rp "mohi-io-www/dist" "/var/www" \
  && apt-get clean \
  && apt-get autoclean -y \
  && apt-get autoremove -y \
  ca-certificates \
  git \
  curl \
  && rm -rf mohi-io-www \
  && rm -rf /usr/local/lib/node_modules

ADD nginx.conf /etc/nginx.conf

# docker build --rm=true -t mohi-io-www .
# docker run --name mohi-io-www-nginx -d -p 8080:80 mohi-io-www


EXPOSE 80