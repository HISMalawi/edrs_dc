#!/bin/bash
PROCESS_FILE="/tmp/edrs_replication_process.pid"

if [ -f $PROCESS_FILE ] ; then
  exit
fi

touch $PROCESS_FILE

DC_PROTOCOL=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:protocol]"`
DC_HOST=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:host]"`
DC_PORT=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:port]"`
DC_USERNAME=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:username]"`
DC_PASSWORD=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:password]"`
DC_DB=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:primary]"`

HQ_PROTOCOL=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:hq][:protocol]"`
HQ_HOST=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:hq][:host]"`
HQ_PORT=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:hq][:port]"`
HQ_USERNAME=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:hq][:username]"`
HQ_PASSWORD=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:hq][:password]"`
HQ_DB=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:hq][:primary]"`

SOURCE_URL="${DC_PROTOCOL}://${DC_HOST}:${DC_PORT}/${DC_DB}"
AUTH_SOURCE_URL="${DC_PROTOCOL}://${DC_USERNAME}:${DC_PASSWORD}@${DC_HOST}:${DC_PORT}"

TARGET_URL="${HQ_PROTOCOL}://${HQ_HOST}:${HQ_PORT}/${HQ_DB}"
AUTH_TARGET_URL="${HQ_PROTOCOL}://${HQ_USERNAME}:${HQ_PASSWORD}@${HQ_HOST}:${HQ_PORT}"

SYNC_FROM_HQ=`eval curl -s -k -H \"Content-Type: application/json\" -X POST -d \'{\"source\": \"${SOURCE_URL}\", \"target\": \"${TARGET_URL}\", \"continuous\": true }\' \"${AUTH_TARGET_URL}/_replicate\"`
SYNC_TO_HQ=`eval curl -s -k -H \"Content-Type: application/json\" -X POST -d \'{\"source\": \"${TARGET_URL}\", \"target\": \"${SOURCE_URL}\", \"continuous\": true }\' \"${AUTH_SOURCE_URL}/_replicate\"`

if [ -f $PROCESS_FILE ] ; then
  rm $PROCESS_FILE
fi
echo ">>>>>>>>>>>>>>>>>DONE"
exit