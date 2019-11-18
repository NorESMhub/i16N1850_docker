FROM centos:7

#####EXTRA LABELS#####
LABEL autogen="no" \ 
    software="CESM" \ 
    version="2" \
    software.version="2.1.1" \ 
    about.summary="Community Earth System Model" \ 
    base_image="centos-7" \
    about.home="NorESM i16N1850" \
    about.license="Copyright (c) 2017, University Corporation for Atmospheric Research (UCAR). All rights reserved." 
      
MAINTAINER Anne Fouilloux <annefou@geo.uio.no>

RUN yum group install "Development Tools" -y && \
    yum install wget cmake "perl(XML::LibXML)"  \
    vim csh git subversion -y

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

RUN adduser centos && usermod -a -G users centos

USER centos

RUN mkdir -p /home/centos/.cime \
             /home/centos/packages \
             /home/centos/intel_license \
             /home/centos/work \
             /home/centos/inputdata \
             /home/centos/archive \
             /home/centos/cases 

COPY config_files/* /home/centos/.cime/

ENV AR=ar

ENV USER=centos

WORKDIR /home/centos

COPY run_noresm /home/centos/

#ENTRYPOINT ./run_noresm

CMD ["/home/centos/run_noresm"]

