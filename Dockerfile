# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# @trenpixster wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return
# ----------------------------------------------------------------------------

# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
#
# Usage Example : Run One-Off commands
# where <VERSION> is one of the baseimage-docker version numbers.
# See : https://github.com/phusion/baseimage-docker#oneshot for more examples.
#
#  docker run --rm -t -i phusion/baseimage:<VERSION> /sbin/my_init -- bash -l
#
# Thanks to @hqmq_ for the heads up
FROM phusion/baseimage:0.9.13
MAINTAINER Nizar Venturini @trenpixster

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT 2014-09-10

# Set correct environment variables.

# Setting ENV HOME does not seem to work currently. HOME is unset in Docker container.
# See bug : https://github.com/phusion/baseimage-docker/issues/119
#ENV HOME /root
# Workaround:
RUN echo /root > /etc/container_environment/HOME

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Baseimage-docker enables an SSH server by default, so that you can use SSH
# to administer your container. In case you do not want to enable SSH, here's
# how you can disable it. Uncomment the following:
#RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /tmp

# See : https://github.com/phusion/baseimage-docker/issues/58
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Update repos
RUN apt-get -qq update

# Install wget
RUN apt-get install -y wget

# Install unzip
RUN apt-get install -y unzip

# Install git
RUN apt-get install -y git

# Add Erlang Solutions repo
# See : https://www.erlang-solutions.com/downloads/download-erlang-otp
RUN echo "deb http://packages.erlang-solutions.com/ubuntu trusty contrib" >> /etc/apt/sources.list
RUN wget http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc
RUN apt-key add erlang_solutions.asc
RUN apt-get -qq update

# Download and Install Specific Version of Erlang
RUN apt-get install -y erlang=1:17.1

# Download and Install Specific Version of Elixir
WORKDIR /elixir
RUN wget -q https://github.com/elixir-lang/elixir/releases/download/v1.0.0-rc2/Precompiled.zip
RUN unzip Precompiled.zip
RUN rm -f Precompiled.zip
RUN ln -s /elixir/bin/elixirc /usr/local/bin/elixirc
RUN ln -s /elixir/bin/elixir /usr/local/bin/elixir
RUN ln -s /elixir/bin/mix /usr/local/bin/mix
RUN ln -s /elixir/bin/iex /usr/local/bin/iex

# Install local Elixir hex and rebar
RUN /usr/local/bin/mix local.hex --force
RUN /usr/local/bin/mix local.rebar --force

WORKDIR /

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
