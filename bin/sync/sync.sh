#!/bin/bash
trim()
{
    local trimmed="$1"

    # Strip leading space.
    trimmed="${trimmed## }"
    # Strip trailing space.
    trimmed="${trimmed%% }"

    echo "$trimmed"
}

PROCESS_FILE="/tmp/edrs_replication_process.pid"

if [ -f $PROCESS_FILE ] ; then
  exit
fi

touch $PROCESS_FILE

SITE_TYPE="$(trim `ruby -ryaml -e "puts YAML::load_file('../../config/settings.yml')['site_type']"`)"

if [ "$SITE_TYPE" = "facility" ]; then
	SOURCE_PROTOCOL=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:fc][:protocol]"`
	SOURCE_HOST=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:fc][:host]"`
	SOURCE_PORT=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:fc][:port]"`
	SOURCE_USERNAME=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:fc][:username]"`
	SOURCE_PASSWORD=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:fc][:password]"`
	SOURCE_DB=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:fc][:primary]"`

	TARGET_PROTOCOL=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:protocol]"`
	TARGET_HOST=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:host]"`
	TARGET_PORT=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:port]"`
	TARGET_USERNAME=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:username]"`
	TARGET_PASSWORD=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:password]"`
	TARGET_DB=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:primary]"`
else

	SOURCE_PROTOCOL=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:protocol]"`
	SOURCE_HOST=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:host]"`
	SOURCE_PORT=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:port]"`
	SOURCE_USERNAME=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:username]"`
	SOURCE_PASSWORD=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:password]"`
	SOURCE_DB=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:dc][:primary]"`

	TARGET_PROTOCOL=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:hq][:protocol]"`
	TARGET_HOST=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:hq][:host]"`
	TARGET_PORT=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:hq][:port]"`
	TARGET_USERNAME=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:hq][:username]"`
	TARGET_PASSWORD=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:hq][:password]"`
	TARGET_DB=`ruby -ryaml -e "puts YAML::load_file('../../config/sync_settings.yml')[:hq][:primary]"`
fi

DISTRICT_CODE=`ruby -ryaml -e "puts YAML::load_file('../../config/settings.yml')[:district_code]"`
FACILITY_CODE=`ruby -ryaml -e "puts YAML::load_file('../../config/settings.yml')[:facility_code]"`

SOURCE_URL="${SOURCE_PROTOCOL}://${SOURCE_USERNAME}:${SOURCE_PASSWORD}@${SOURCE_HOST}:${SOURCE_PORT}/${SOURCE_DB}"
AUTH_SOURCE_URL="${SOURCE_PROTOCOL}://${SOURCE_USERNAME}:${SOURCE_PASSWORD}@${SOURCE_HOST}:${SOURCE_PORT}"

TARGET_URL="${TARGET_PROTOCOL}://${TARGET_USERNAME}:${TARGET_PASSWORD}@${TARGET_HOST}:${TARGET_PORT}/${TARGET_DB}"
AUTH_TARGET_URL="${TARGET_PROTOCOL}://${TARGET_USERNAME}:${TARGET_PASSWORD}@${TARGET_HOST}:${TARGET_PORT}"

SYNC_TO_TARGET=`eval curl -s -k -H \"Content-Type: application/json\" -X POST -d \'{\"source\": \"${SOURCE_URL}\", \"target\": \"${TARGET_URL}\", \"continuous\": true }\' \"${AUTH_SOURCE_URL}/_replicate\"`
if [ "$SITE_TYPE" = "dc" ]; then
	SYNC_PEOPLE_FROM_TARGET=`eval curl -s -k -H \"Content-Type: application/json\" -X POST -d \'{\"source\": \"${TARGET_URL}\", \"target\": \"${SOURCE_URL}\", \"continuous\": true, \"filter\": \"Person/district_sync\", \"query_params\": {\"district_code\": \"${DISTRICT_CODE}\"}}\' \"${AUTH_SOURCE_URL}/_replicate\"`
	SYNC_IDENTIFIER_FROM_TARGET=`eval curl -s -k -H \"Content-Type: application/json\" -X POST -d \'{\"source\": \"${TARGET_URL}\", \"target\": \"${SOURCE_URL}\", \"continuous\": true, \"filter\": \"PersonIdentifier/district_sync\", \"query_params\": {\"district_code\": \"${DISTRICT_CODE}\"}}\' \"${AUTH_SOURCE_URL}/_replicate\"`
	SYNC_AUDITS_FROM_TARGET=`eval curl -s -k -H \"Content-Type: application/json\" -X POST -d \'{\"source\": \"${TARGET_URL}\", \"target\": \"${SOURCE_URL}\", \"continuous\": true, \"filter\": \"Audit/facility_sync\", \"query_params\": {\"site_id\": \"${DISTRICT_CODE}\"}}\' \"${AUTH_SOURCE_URL}/_replicate\"`
	SYNC_STATUSES_FROM_TARGET=`eval curl -s -k -H \"Content-Type: application/json\" -X POST -d \'{\"source\": \"${TARGET_URL}\", \"target\": \"${SOURCE_URL}\", \"continuous\": true, \"filter\": \"PersonRecordStatus/district_sync\", \"query_params\": {\"district_code\": \"${DISTRICT_CODE}\"}}\' \"${AUTH_SOURCE_URL}/_replicate\"`
	SYNC_BARCODE_FROM_TARGET=`eval curl -s -k -H \"Content-Type: application/json\" -X POST -d \'{\"source\": \"${TARGET_URL}\", \"target\": \"${SOURCE_URL}\", \"continuous\": true, \"filter\": \"Barcode/assigned_sync\", \"query_params\": {\"assigned\": \"true\"}}\' \"${AUTH_SOURCE_URL}/_replicate\"`
elif [ "$SITE_TYPE" = "facility" ]; then
	SYNC_PEOPLE_FROM_TARGET=`eval curl -s -k -H \"Content-Type: application/json\" -X POST -d \'{\"source\": \"${TARGET_URL}\", \"target\": \"${SOURCE_URL}\", \"continuous\": true, \"filter\": \"Person/facility_sync\", \"query_params\": {\"facility_code\": \"${FACILITY_CODE}\"}}\' \"${AUTH_SOURCE_URL}/_replicate\"`
	SYNC_IDENTIFIER_FROM_TARGET=`eval curl -s -k -H \"Content-Type: application/json\" -X POST -d \'{\"source\": \"${TARGET_URL}\", \"target\": \"${SOURCE_URL}\", \"continuous\": true, \"filter\": \"PersonIdentifier/facility_sync\", \"query_params\": {\"district_code\": \"${FACILITY_CODE}\"}}\' \"${AUTH_SOURCE_URL}/_replicate\"`
	SYNC_AUDITS_FROM_TARGET=`eval curl -s -k -H \"Content-Type: application/json\" -X POST -d \'{\"source\": \"${TARGET_URL}\", \"target\": \"${SOURCE_URL}\", \"continuous\": true, \"filter\": \"Audit/facility_sync\", \"query_params\": {\"site_id\": \"${FACILITY_CODE}\"}}\' \"${AUTH_SOURCE_URL}/_replicate\"`
	SYNC_STATUSES_FROM_TARGET=`eval curl -s -k -H \"Content-Type: application/json\" -X POST -d \'{\"source\": \"${TARGET_URL}\", \"target\": \"${SOURCE_URL}\", \"continuous\": true, \"filter\": \"PersonRecordStatus/facility_sync\", \"query_params\": {\"facility_code\": \"${FACILITY_CODE}\"}}\' \"${AUTH_SOURCE_URL}/_replicate\"`
	SYNC_BARCODE_FROM_TARGET=`eval curl -s -k -H \"Content-Type: application/json\" -X POST -d \'{\"source\": \"${TARGET_URL}\", \"target\": \"${SOURCE_URL}\", \"continuous\": true, \"filter\": \"Barcode/assigned_sync\", \"query_params\": {\"assigned\": \"true\"}}\' \"${AUTH_SOURCE_URL}/_replicate\"`
else
	SYNC_FROM_TARGET=`eval curl -s -k -H \"Content-Type: application/json\" -X POST -d \'{\"source\": \"${TARGET_URL}\", \"target\": \"${SOURCE_URL}\", \"continuous\": true }\' \"${AUTH_SOURCE_URL}/_replicate\"`
fi


if [ -f $PROCESS_FILE ] ; then
  rm $PROCESS_FILE
fi
echo ">>>>>>>>>>>>>>>>>DONE"
exit