#!/bin/bash
ENV=$1
DC_PROTOCOL=`ruby -ryaml -e "puts YAML::load_file('../config/couchdb.yml')['${ENV}'][:protocol]"`
DC_HOST=`ruby -ryaml -e "puts YAML::load_file('../config/couchdb.yml')['${ENV}'][:host]"`
DC_PORT=`ruby -ryaml -e "puts YAML::load_file('../config/couchdb.yml')['${ENV}'][:port]"`
DC_USERNAME=`ruby -ryaml -e "puts YAML::load_file('../config/couchdb.yml')['${ENV}'][:username]"`
DC_PASSWORD=`ruby -ryaml -e "puts YAML::load_file('../config/couchdb.yml')['${ENV}'][:password]"`
DC_DB_PREFIX=`ruby -ryaml -e "puts YAML::load_file('../config/couchdb.yml')['${ENV}'][:prefix]"`
DC_DB_SUFFIX=`ruby -ryaml -e "puts YAML::load_file('../config/couchdb.yml')['${ENV}'][:suffix]"`