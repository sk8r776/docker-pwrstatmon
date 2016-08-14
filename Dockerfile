FROM centos:latest

MAINTAINER Sk8r776

RUN yum install -y wget

RUN wget https://dl4jz3rbrsfum.cloudfront.net/software/powerpanel-132-0x86_64.rpm -O /tmp/powerpanel-132-0x86_64.rpm

RUN rpm -ivh /tmp/powerpanel_132_amd64.deb

RUN wget https://raw.githubusercontent.com/sk8r776/docker-pwrstatmon/master/run%20scripts/check_ups_status_essos.sh -O /tmp/check_ups_status.sh \
	mv /tmp/check_ups_status.sh /usr/local/bin/check_ups_status \
	chmod +x /usr/local/bin/check_ups_status

CMD ["check_ups_status"]