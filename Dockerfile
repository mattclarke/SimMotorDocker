FROM ubuntu:xenial

USER root

# Install the things needed
RUN apt-get update \
    && apt-get install -yq build-essential \
    && apt-get install -yq libreadline6 libreadline6-dev \
    && apt-get install -yq wget \
    && apt-get install -yq git

# Download EPICS base
RUN wget --quiet https://epics.anl.gov/download/base/base-3.15.5.tar.gz \
    && tar xvzf base-3.15.5.tar.gz \
    && mkdir /opt/epics \
    && mv base-3.15.5 /opt/epics/base \
    && rm base-3.15.5.tar.gz 

# Download ASYN
RUN wget --quiet https://www.aps.anl.gov/epics/download/modules/asyn4-33.tar.gz \
    && tar xvzf asyn4-33.tar.gz \
    && mkdir /opt/epics/modules  \
    && mv asyn4-33 asyn \
    && mv asyn /opt/epics/modules \
    && rm asyn4-33.tar.gz
    
# Copy in custom RELEASE file
COPY files/RELEASE /opt/epics/modules/asyn/configure/.

# Build EPICS base and ASYN
RUN cd /opt/epics/base && make \
    && cd /opt/epics/modules/asyn && make

# Download SimMotor from git and build it
RUN mkdir /opt/epics/iocs \
    && git clone https://github.com/mattclarke/SimMotor.git /opt/epics/iocs/SimMotor \
    && cd /opt/epics/iocs/SimMotor && make

# Expose the standard EPICS ports
EXPOSE 5064 5065 5064/udp

# Start the IOC
CMD cd /opt/epics/iocs/SimMotor/iocBoot/iocSim/ && ../../bin/linux-x86_64/WithAsyn st.cmd.unix
