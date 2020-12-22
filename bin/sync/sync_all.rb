@settings = SYNC_SETTINGS
person_count = Person.count

source = @settings[:dc]
hq = @settings[:hq]

source_to_target = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
              target: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
              connection_timeout: 60000,
              retries_per_request: 20,
              http_connections: 30,
              continuous: true
                }.to_json}' "#{hq[:protocol]}://#{hq[:username]}:#{hq[:password]}@#{hq[:host]}:#{hq[:port]}/_replicate"]                 

puts "There are #{person_count } people"

if hq[:bidirectional] == true

    target_to_source = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
              target: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
              connection_timeout: 60000,
              retries_per_request: 20,
              http_connections: 30,
              continuous: true
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]
end



        
                  
        
                
