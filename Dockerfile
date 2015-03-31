FROM ubuntu:14.04
 
  
#propairs dependencies
RUN apt-get update && apt-get install -y \ 
   bsdmainutils \
   make \
   r-base \
   rsync \
   wget
# postgres
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
   postgresql-9.3 \
   postgresql-contrib-9.3 \
   postgresql-9.3-postgis-2.1 \
   libpq-dev \
   sudo \
   netcat-traditional
RUN echo "local all  postgres  peer " >  /etc/postgresql/9.3/main/pg_hba.conf && \
   echo  "local all  all       trust" >> /etc/postgresql/9.3/main/pg_hba.conf && \
   /etc/init.d/postgresql start && \
   sudo -u postgres createuser -s ppiuser && \
   sudo -u postgres createdb -O ppiuser ppidb1

# biopython dependencies
RUN apt-get update && apt-get install -y \
   python2.7 \
   python2.7-dev \
   python2.7-numpy

# xtal dependencies
RUN apt-get update && apt-get install -y \ 
   g++-4.8 \
   make \
   r-base \
   wget


# setup propairs programm
COPY . /opt/propairs
RUN cd /opt/propairs && make
ENV PROPAIRSROOT /opt/propairs/


# path where to write data set and temp files
VOLUME ["/data/"]

RUN groupadd -r swuser -g 433 && \
   useradd -u 431 -r -g ppuser -d /home/ppuser -s /sbin/nologin -c "ProPairs user" ppuser && \
   chown -R ppuser:ppuser /home/ppuser

USER ppuser

# create data set    
# (TODO: find clean way to pass aruments)
# CMD ["/bin/bash", "-c" ,"/etc/init.d/postgresql start && /opt/propairs/start.sh /opt/propairs/ /data/"]
ENTRYPOINT ["/bin/bash", "-c" ,"/etc/init.d/postgresql start && /opt/propairs/start.sh /opt/propairs/ /data/"]

