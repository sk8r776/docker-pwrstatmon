FROM centos:latest

MAINTAINER Sk8r776

RUN yum install -y wget

RUN wget https://dl4jz3rbrsfum.cloudfront.net/software/powerpanel-132-0x86_64.rpm -O /tmp/powerpanel-132-0x86_64.rpm

RUN rpm -ivh /tmp/powerpanel_132_amd64.deb