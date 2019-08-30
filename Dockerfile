FROM debian:stretch

RUN apt-get update

RUN apt-get install -y git git-svn subversion

ADD migrate /root/migrate
ADD openssl.cnf /etc/ssl/openssl.cnf

RUN chmod +x /root/migrate

WORKDIR /root 