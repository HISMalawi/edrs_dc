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