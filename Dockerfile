# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# @trenpixster wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return
# ----------------------------------------------------------------------------

# Thanks to @hqmq_ for the heads up
FROM phusion/baseimage:0.9.13
MAINTAINER Nizar Venturini @trenpixster

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /tmp

# Update repos
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections # from https://github.com/phusion/baseimage-docker/issues/58

RUN apt-get update

# Install wget
RUN apt-get install -y wget

# Install unzip
RUN apt-get install -y unzip

# Add Erlang Solutions repo
RUN echo "deb http://packages.erlang-solutions.com/ubuntu trusty contrib" >> /etc/apt/sources.list
RUN wget http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc
RUN apt-key add erlang_solutions.asc
RUN apt-get update

# Install Erlang
RUN sudo apt-get install -y erlang

# Download and Install Elixir
WORKDIR /elixir
RUN wget https://github.com/elixir-lang/elixir/releases/download/v1.0.0-rc1/Precompiled.zip
RUN unzip Precompiled.zip
RUN ln -s  /elixir/bin/elixirc /usr/local/bin/elixirc
RUN ln -s  /elixir/bin/elixir /usr/local/bin/elixir
RUN ln -s /elixir/bin/mix /usr/local/bin/mix
RUN ln -s  /elixir/bin/iex /usr/local/bin/iex

WORKDIR /
