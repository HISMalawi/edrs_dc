Person.count
@settings = SETTINGS
district_code = CONFIG['district_code']
person_count = Person.count

if CONFIG['site_type'] == "facility"
	source = @settings[:fc]
else
	source = @settings[:dc]
end

hq = @settings[:hq]

target_to_source = %x[curl -k -H 'Content-Type: application/json' -X POST -d '#{{
              source: "#{hq[:protocol]}://#{hq[:host]}:#{hq[:port]}/#{hq[:primary]}",
                  target: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  connection_timeout: 60000,
                  retries_per_request: 20,
                  http_connections: 30,
                  continuous: true
                   }.to_json}' "#{source[:protocol]}://#{source[:username]}:#{source[:password]}@#{source[:host]}:#{source[:port]}/_replicate"]
   
JSON.parse(target_to_source).each do |key, value|
      puts "#{key.to_s.capitalize} : #{value.to_s.capitalize}"
end

puts "\nDistricts :#{District.count} \n"
puts "\nTAs :#{TraditionalAuthority.count} \n"
puts "\nVillages :#{Village.count} \n"




        
                  
        
                
