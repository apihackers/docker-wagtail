FROM apihackers/wagtail:1.12

MAINTAINER API Hackers

# Install some circleci dependencies
RUN apk add --update --no-cache jq openssh

# Enable remote debugging with ssh
RUN /etc/init.d/sshd start

COPY .bashrc /root/

# Install nvm
ENV NVM_VERSION 0.33.5
ENV NVM_DIR /root/.nvm
# NVM is failing with -e option
RUN echo '\n# Failsafe NVM activation\nset +e' >> /root/.bashrc
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash
RUN echo '\nset -e' >> /root/.bashrc

# Upgrade to latest virtualenv version
RUN pip install -U virtualenv
