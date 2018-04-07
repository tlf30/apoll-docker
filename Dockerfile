from fedora:27
MAINTAINER Trevor Flynn <trevorflynn@liquidcrystalstudios.com>

USER root
WORKDIR /root

# Install needed tools
RUN dnf  clean metadata && dnf --setopt=deltarpm=false update -y && dnf --setopt=deltarpm=false -y install sudo java-1.8.0-openjdk java-1.8.0-openjdk-devel gradle git && dnf clean all

# Add user for apollo
RUN groupadd -r apollo -g 1000 && useradd -u 1000 -r -g apollo -m -d /opt/apollo -s /sbin/nologin -c "Apollo server user" apollo && \
    chmod 755 /opt/apollo

# Swwap into apollo user and begin install	
USER apollo	
WORKDIR /opt/apollo

# Set apollo version/git branch here
ENV APOLLO_VERSION kotlin-experiments

RUN git clone https://github.com/apollo-rsps/apollo.git && mv ./apollo server

# Build apollo
WORKDIR /opt/apollo/server
RUN git checkout origin/${APOLLO_VERSION} && gradle assemble build && rm -rf /opt/apollo/server/data/*

# Configure firewall
USER root
EXPOSE 43594
EXPOSE 8080
EXPOSE 43595
RUN setcap 'cap_net_bind_service=+ep' `readlink -f $(which java)`

USER apollo

CMD ["gradle", "run"]

