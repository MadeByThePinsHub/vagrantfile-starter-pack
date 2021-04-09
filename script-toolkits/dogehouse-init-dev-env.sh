#!/bin/sh

########## RabbitMQ ##########
## Copy-pasta from https://www.rabbitmq.com/install-debian.html#apt-quick-start
## In this file, we replaced bionic with focal to reflect to the Vargant box that
## we want to use, in this case, the official cloud image of Ubuntu 20.04 from Canonical
sudo apt-get install curl gnupg debian-keyring debian-archive-keyring apt-transport-https -y

## Team RabbitMQ's main signing key
sudo apt-key adv --keyserver "hkps://keys.openpgp.org" --recv-keys "0x0A9AF2115F4687BD29803A206B73A36E6026DFCA"
## Launchpad PPA that provides modern Erlang releases
sudo apt-key adv --keyserver "keyserver.ubuntu.com" --recv-keys "F77F1EDA57EBB1CC"
## PackageCloud RabbitMQ repository
sudo apt-key adv --keyserver "keyserver.ubuntu.com" --recv-keys "F6609E60DC62814E"

## Add apt repositories maintained by Team RabbitMQ
sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Provides modern Erlang/OTP releases
##
## "bionic" as distribution name should work for any reasonably recent Ubuntu or Debian release.
## See the release to distribution mapping table in RabbitMQ doc guides to learn more.
deb http://ppa.launchpad.net/rabbitmq/rabbitmq-erlang/ubuntu focal main
deb-src http://ppa.launchpad.net/rabbitmq/rabbitmq-erlang/ubuntu focal main
## Provides RabbitMQ
##
## "bionic" as distribution name should work for any reasonably recent Ubuntu or Debian release.
## See the release to distribution mapping table in RabbitMQ doc guides to learn more.
deb https://packagecloud.io/rabbitmq/rabbitmq-server/ubuntu/ focal main
deb-src https://packagecloud.io/rabbitmq/rabbitmq-server/ubuntu/ focal main
EOF

## Update package indices
sudo apt-get update -y

## Install Erlang packages
sudo apt-get install -y erlang-base \
                        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                        erlang-runtime-tools erlang-snmp erlang-ssl \
                        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl

## Install rabbitmq-server and its dependencies
sudo apt-get install rabbitmq-server -y --fix-missing

## ensure the service is up
sudo systemctl enable --now rabbitmq-server

########## Node.js and friends ##########
curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs
## DogeHouse maintainer, Ben Awad, prefer to use Yarn instead of
## npm for workspaces stuff, among other things.
sudo npm install -g yarn

########## PostgresSQL ##########
## Instructions are based on https://www.postgresqltutorial.com/install-postgresql-linux/
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update && sudo apt-get install postgres -y

## ensure the server is up
sudo systemctl enable --now postgresql

## Init database
sudo -u postgres psql -c "CREATE DATABASE kousa_repo2" postgres

########### Elixir ##########
## Since we installed Erlang in the erailer stage for RabbitMQ
## We can just install Elixir stuff instead of doing the Erlang install again
wget -O "/tmp/erlang-solutions_2.0_all.deb" https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
sudo dpkg -i /tmp/erlang-solutions_2.0_all.deb

## let's do the cache update again, maybe do this one after
## adding repos instead later
sudo apt-get update
## blame the install guide (https://elixir-lang.org/install.html) but we should be fine
udo apt-get install elixir -y
