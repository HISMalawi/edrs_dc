RecordStatus.where("status IN('HQ CAN PRINT','HQ CAN RE PRINT','HQ CAN PRINT AMENDED','HQ CAN PRINT LOST','HQ CAN PRINT DAMAGED') AND voided = 0 AND district_code='#{SETTINGS['district_code']}'").each do |d|
    next if File.exist?("#{SETTINGS['qrcodes_path']}QR#{d.person_record_id}.png")
    `rails r bin/generate_qr_code #{d.person_record_id} #{SETTINGS['qrcodes_path']}`    
end

RecordStatus.where("status IN('HQ CAN PRINT','HQ CAN RE PRINT','HQ CAN PRINT AMENDED', 'HQ CAN PRINT LOST','HQ CAN PRINT DAMAGED') AND voided = 0 AND district_code='#{SETTINGS['district_code']}'" ).each do |d|
    status = PersonRecordStatus.by_person_recent_status.key(d.person_record_id).last
 	  #raise status.inspect
    if status.present? && ['HQ CAN PRINT','HQ CAN RE PRINT','HQ CAN PRINT AMENDED','HQ CAN PRINT LOST','HQ CAN PRINT DAMAGED'].include?(status.status)
	status.insert_update_into_mysql
	next
    else
	status.insert_update_into_mysql  if status.present?
        PersonRecordStatus.by_person_record_id.key(d.person_record_id).each do |s|
            s.insert_update_into_mysql
        end
        d.voided = 1
        d.save
    end
end
