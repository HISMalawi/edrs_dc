@settings = SYNC_SETTINGS
district_code = SETTINGS['district_code']
person_count = Person.count

source = @settings[:dc]
hq = @settings[:hq]

source_to_target = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/#{source[:primary]}",
              target: "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
              connection_timeout: 60000,
              retries_per_request: 20,
              http_connections: 30,
              continuous: true,
              filter: 'Person/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                            }
                }.to_json}' "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/_replicate"] 

source_to_target = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/#{source[:primary]}",
              target: "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
              connection_timeout: 60000,
              retries_per_request: 20,
              http_connections: 30,
              continuous: true,
              filter: 'PersonIdentifier/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                            }
                }.to_json}' "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/_replicate"]

source_to_target = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/#{source[:primary]}",
              target: "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
              connection_timeout: 60000,
              retries_per_request: 20,
              http_connections: 30,
              continuous: true,
              filter: 'Audit/facility_sync',
                  query_params: {
                      site_id: "#{district_code}"
                            }
                }.to_json}' "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/_replicate"]  

source_to_target = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/#{source[:primary]}",
              target: "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
              connection_timeout: 60000,
              retries_per_request: 20,
              http_connections: 30,
              continuous: true,
              filter: 'Sync/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                            }
                }.to_json}' "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/_replicate"] 
                  
source_to_target = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/#{source[:primary]}",
              target: "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
              connection_timeout: 60000,
              retries_per_request: 20,
              http_connections: 30,
              continuous: true,
              filter: 'PersonRecordStatus/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                            }
                }.to_json}' "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/_replicate"]             

puts "There are #{person_count } people"

if hq[:bidirectional] == true

    target_to_source = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
                  target: "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  connection_timeout: 60000,
                  filter: 'Person/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                            }
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]
   
    JSON.parse(target_to_source).each do |key, value|
      puts "#{key.to_s.capitalize} : #{value.to_s.capitalize}"
    end

    person_ids_status_target_to_source = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
                  target: "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  connection_timeout: 60000,
                  filter: 'PersonIdentifier/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                            }
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]
   
    JSON.parse(person_ids_status_target_to_source).each do |key, value|
      puts "#{key.to_s.capitalize} : #{value.to_s.capitalize}"
    end

    audits_target_to_source = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
                  target: "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  connection_timeout: 60000,
                  filter: 'Audit/facility_sync',
                  query_params: {
                      site_id: "#{district_code}"
                            }
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]
   
    JSON.parse(audits_target_to_source).each do |key, value|
      puts "#{key.to_s.capitalize} : #{value.to_s.capitalize}"
    end

    sync_target_to_source = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
                  target: "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  connection_timeout: 60000,
                  filter: 'Sync/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                            }
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]
   
    JSON.parse(sync_target_to_source).each do |key, value|
      puts "#{key.to_s.capitalize} : #{value.to_s.capitalize}"
    end

    record_status_target_to_source = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
                  target: "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  connection_timeout: 60000,
                  filter: 'PersonRecordStatus/district_sync',
                  query_params: {
                      district_code: "#{district_code}"
                            }
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]
   
    JSON.parse(record_status_target_to_source).each do |key, value|
      puts "#{key.to_s.capitalize} : #{value.to_s.capitalize}"
    end
end



        
                  
        
                
