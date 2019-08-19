FROM ubuntu:xenial

USER root

# Install the things needed
RUN apt-get update
RUN apt-get install -yq build-essential
RUN apt-get install -yq libreadline6 libreadline6-dev
RUN apt-get install -yq wget
RUN apt-get install -yq git

# Download EPICS base
RUN wget --quiet https://epics.anl.gov/download/base/base-3.15.5.tar.gz
RUN tar xvzf base-3.15.5.tar.gz
RUN mkdir /opt/epics
RUN mv base-3.15.5 /opt/epics/base
RUN rm base-3.15.5.tar.gz

# Download ASYN
RUN wget --quiet https://www.aps.anl.gov/epics/download/modules/asyn4-33.tar.gz
RUN tar xvzf asyn4-33.tar.gz
RUN mkdir /opt/epics/modules
RUN mv asyn4-33 asyn
RUN mv asyn /opt/epics/modules
# Copy in custom RELEASE file
COPY files/RELEASE /opt/epics/modules/asyn/configure/.
RUN rm asyn4-33.tar.gz

# Build EPICS base
RUN cd /opt/epics/base && make

# Build ASYN
RUN cd /opt/epics/modules/asyn && make

# Download SimMotor from git and build it
RUN mkdir /opt/epics/iocs
RUN git clone https://github.com/mattclarke/SimMotor.git /opt/epics/iocs/SimMotor
RUN cd /opt/epics/iocs/SimMotor && make

# Expose the standard EPICS ports
EXPOSE 5064 5065
EXPOSE 5064/udp

# Start the IOC
CMD cd /opt/epics/iocs/SimMotor/iocBoot/iocSim/ && ../../bin/linux-x86_64/WithAsyn st.cmd.unix
