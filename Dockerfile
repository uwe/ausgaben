FROM phusion/baseimage
RUN apt-get update -y
RUN apt-get install -y build-essential perl
RUN curl -L http://cpanmin.us | perl - App::cpanminus

ADD . /app
WORKDIR /app
RUN cpanm --installdeps .

RUN cpanm Starman

CMD starman --preload-app --port 5000
