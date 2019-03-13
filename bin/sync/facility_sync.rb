@settings = SYNC_SETTINGS
facility_code = SETTINGS['facility_code']
district_code = SETTINGS['district_code']
person_count = Person.count

fc = @settings[:fc]
dc = @settings[:dc]

source_to_target = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{fc[:protocol]}://#{fc[:host]}:#{fc[:port]}/#{fc[:primary]}",
              target: "#{dc[:protocol]}://#{dc[:host]}:#{dc[:port]}/#{dc[:primary]}",
              connection_timeout: 60000,
              retries_per_request: 20,
              http_connections: 30,
              continuous: true
                }.to_json}' "#{dc[:protocol]}://#{dc[:username]}:#{dc[:password]}@#{dc[:host]}:#{dc[:port]}/_replicate"]                

if dc[:bidirectional] == true
    target_to_source = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
                  source: "#{dc[:protocol]}://#{dc[:host]}:#{dc[:port]}/#{dc[:primary]}",
                  target: "#{fc[:protocol]}://#{fc[:host]}:#{fc[:port]}/#{fc[:primary]}",
                  connection_timeout: 60000,
                  filter: 'Person/facility_sync',
              		query_params: {
        		     			facility_code: "#{facility_code}"
                            }
               		 }.to_json}' "#{fc[:protocol]}://#{fc[:username]}:#{fc[:password]}@#{fc[:host]}:#{fc[:port]}/_replicate"]

  

    pid_target_to_source = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
                  source: "#{dc[:protocol]}://#{dc[:host]}:#{dc[:port]}/#{dc[:primary]}",
                  target: "#{fc[:protocol]}://#{fc[:host]}:#{fc[:port]}/#{fc[:primary]}",
                  connection_timeout: 60000,
                  filter: 'PersonIdentifier/facility_sync',
                  query_params: {
                      facility_code: "#{facility_code}"
                            }
                   }.to_json}' "#{fc[:protocol]}://#{fc[:username]}:#{fc[:password]}@#{fc[:host]}:#{fc[:port]}/_replicate"]



    audits_target_to_source = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
                  source: "#{dc[:protocol]}://#{dc[:host]}:#{dc[:port]}/#{dc[:primary]}",
                  target: "#{fc[:protocol]}://#{fc[:host]}:#{fc[:port]}/#{fc[:primary]}",
                  connection_timeout: 60000,
                  filter: 'Audit/facility_sync',
                  query_params: {
                      facility_code: "#{facility_code}"
                            }
                   }.to_json}' "#{fc[:protocol]}://#{fc[:username]}:#{fc[:password]}@#{fc[:host]}:#{fc[:port]}/_replicate"]
   

    sync_target_to_source = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
                source: "#{dc[:protocol]}://#{dc[:host]}:#{dc[:port]}/#{dc[:primary]}",
                target: "#{fc[:protocol]}://#{fc[:host]}:#{fc[:port]}/#{fc[:primary]}",
                connection_timeout: 60000,
                filter: 'Sync/facility_sync',
                query_params: {
                      facility_code: "#{facility_code}"
                            }
                   }.to_json}' "#{fc[:protocol]}://#{fc[:username]}:#{fc[:password]}@#{fc[:host]}:#{fc[:port]}/_replicate"]
   

    record_status_target_to_source = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{dc[:protocol]}://#{dc[:host]}:#{dc[:port]}/#{dc[:primary]}",
              target: "#{fc[:protocol]}://#{fc[:host]}:#{fc[:port]}/#{fc[:primary]}",
              connection_timeout: 60000,
              filter: 'PersonRecordStatus/facility_sync',
              query_params: {
                      facility_code: "#{facility_code}"
                            }
                   }.to_json}' "#{fc[:protocol]}://#{fc[:username]}:#{fc[:password]}@#{fc[:host]}:#{fc[:port]}/_replicate"]
   
end 