require "net/http"
require "json"
puts "Push data to remote"
connection = ActiveRecord::Base.connection
query = "SELECT * FROM push_sync_tracker WHERE sync_status = 0"
connection.select_all(query).as_json.each_with_index do |d, i|
     type = d["type"]
     record = eval(type).find(d["record_id"]) rescue nil
     next if record.blank?
     puts "Push to Record"
     record.save
end

if SETTINGS["site_type"] == "facility"
    url = "#{SYNC_SETTINGS[:dc][:protocol]}://#{SYNC_SETTINGS[:dc][:host]}:#{SYNC_SETTINGS[:dc][:port]}/"
else
    url = "#{SYNC_SETTINGS[:hq][:protocol]}://#{SYNC_SETTINGS[:hq][:host]}:#{SYNC_SETTINGS[:hq][:port]}/"
end

url = URI.parse(url)
req = Net::HTTP.new(url.host, url.port)
res = req.request_head(url.path)

if ["200","201","202","204","302"].include?(res.code.to_s)
    uri = URI("#{url}api/v1/hq_sync?district_code=#{SETTINGS['district_code']}")
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    data.each do |d|
        connection = ActiveRecord::Base.connection
        query = "SELECT * FROM pull_sync_tracker WHERE record_id='#{d['record_id']}' AND sync_status=0;"
        push_record = connection.select_all(query).as_json
        if push_record.count == 0
            insert_query = "INSERT INTO  pull_sync_tracker (record_id,type,sync_status,district_code,created_at,updated_at)
                            VALUES('#{d['record_id']}','#{d['type']}',0,'#{d['district_code']}', '#{DateTime.parse(d['created_at']).strftime('%Y-%m-%d %H:%M:%S')}','#{DateTime.parse(d['updated_at']).strftime('%Y-%m-%d %H:%M:%S')}');"
            SimpleSQL.query_exec(insert_query)
        end
    end
else
end

puts "Push data from remote"
connection = ActiveRecord::Base.connection
query = "SELECT * FROM pull_sync_tracker WHERE sync_status = 0"
connection.select_all(query).as_json.each do |d|
     type = d["type"]
     uri = URI("#{url}api/v1/get_remote_record?record_id=#{d["record_id"]}&type=#{type}")
     response = Net::HTTP.get(uri)
     data = JSON.parse(response)
     record = eval(type).find(d['record_id'])
     record = eval(type).new if record.blank?
     data.keys.each do |d|
        record[d] = data[d]
     end
     if record.save
        update_query = "UPDATE pull_sync_tracker SET sync_status = 1 WHERE record_id='#{d['record_id']}'"
        SimpleSQL.query_exec(update_query)
        uri = URI("#{url}api/v1/update_sync_status?record_id=#{d["record_id"]}&type=#{type}")
        response = Net::HTTP.get(uri)
        puts response
     end
end