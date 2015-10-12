#FROM alpine:3.1
FROM debian:8

MAINTAINER CenturyLink Labs <clt-labs-futuretech@centurylink.com>
ENTRYPOINT ["/usr/src/app/image-graph.sh"]
CMD [""]

RUN apt-get -y -qq update && apt-get -y -qq install ruby-dev graphviz ca-certificates rubygems
RUN gem install --no-rdoc --no-ri docker-api sinatra
RUN dot -c

ADD . /usr/src/app/
WORKDIR /usr/src/app/
