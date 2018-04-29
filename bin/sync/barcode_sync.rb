@settings = SYNC_SETTINGS
district_code = SETTINGS['district_code']

if SETTINGS['site_type'] == "facility"
  target = @settings[:fc]
  source = @settings[:dc]
else
  target = @settings[:dc]
  source = @settings[:hq]
end
assigned = "true"
target_to_source = %x[curl -s -k -H 'Content-Type: application/json' -X POST -d '#{{
                  source: "#{source[:protocol]}://#{source[:host]}:#{source[:port]}/#{source[:primary]}",
                  target: "#{target[:protocol]}://#{target[:host]}:#{target[:port]}/#{target[:primary]}",
                  connection_timeout: 60000,
                  filter: 'Barcode/assigned_sync',
                  query_params: {
                      assigned: "#{assigned}"
                            }
                   }.to_json}' "#{target[:protocol]}://#{target[:username]}:#{target[:password]}@#{target[:host]}:#{target[:port]}/_replicate"]
   
JSON.parse(target_to_source).each do |key, value|
      puts "#{key.to_s.capitalize} : #{value.to_s.capitalize}"
end
