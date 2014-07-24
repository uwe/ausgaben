FROM phusion/baseimage
RUN apt-get update -y
RUN apt-get install -y build-essential perl libmysqlclient-dev
RUN curl -L http://cpanmin.us | perl - App::cpanminus

ADD ~/.ssh/id_rsa.pub /root/.ssh/authorized_keys

ADD . /home/app
WORKDIR /home/app
RUN cpanm --notest --installdeps .
RUN cpanm --notest Starman

CMD plackup
