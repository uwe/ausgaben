FROM phusion/baseimage
RUN apt-get update -y
RUN apt-get install -y build-essential perl libmysqlclient-dev
RUN curl -L http://cpanmin.us | perl - App::cpanminus

ADD . /home/app
RUN mv /home/app/id_rsa.pub /root/.ssh/authorized_keys
WORKDIR /home/app
RUN cpanm --notest --installdeps .
RUN cpanm --notest Starman

CMD plackup
