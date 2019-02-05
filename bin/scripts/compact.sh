#!/bin/bash
ENV=$1
echo $ENV
DC_PROTOCOL=`ruby -ryaml -e "puts YAML::load_file('../config/couchdb.yml')['${ENV}']"`
echo $DC_DB_PROTOCOL
DC_HOST=`ruby -ryaml -e "puts YAML::load_file('../config/couchdb.yml')['${ENV}'][:host]"`
DC_PORT=`ruby -ryaml -e "puts YAML::load_file('../config/couchdb.yml')['${ENV}'][:port]"`
DC_USERNAME=`ruby -ryaml -e "puts YAML::load_file('../config/couchdb.yml')['${ENV}'][:username]"`
DC_PASSWORD=`ruby -ryaml -e "puts YAML::load_file('../config/couchdb.yml')['${ENV}'][:password]"`
DC_DB_PREFIX=`ruby -ryaml -e "puts YAML::load_file('../config/couchdb.yml')['${ENV}'][:prefix]"`
DC_DB_SUFFIX=`ruby -ryaml -e "puts YAML::load_file('../config/couchdb.yml')['${ENV}'][:suffix]"`

DC_DB="${DC_DB_PREFIX}_${DC_DB_SUFFIX}"

COMPACT_URL="${DC_DB_PROTOCOL}://${DC_USERNAME}:${DC_PASSWORD}@${DC_HOST}:${DC_PORT}/${DC_DB}/_compact"
echo $COMPACT_URL
exit


#SYNC_FROM_HQ=`eval curl -H \"Content-Type: application/json\" -XPOST \'\"\"\'`