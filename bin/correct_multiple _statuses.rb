def remove_redu_states(person_id)
    #puts person_id
    statuses = PersonRecordStatus.by_person_record_id.key(person_id).each
    
    uniqstatus = statuses.collect{|d| d.status}.uniq

    uniqstatus.each do |us|
        redundantstatuses = PersonRecordStatus.by_person_record_id_and_status.key([person_id, us]).each.sort_by{|s| s.created_at}
        puts "destroying multiple #{us}"
        redundantstatuses.each_with_index do |red, i|
                if i != 0
                    begin
                        redundantstatuses[i].destroy
                    rescue
                        puts "Error : #{redundantstatuses[i].id}"
                        puts "Retry"
                        begin
                            PersonRecordStatus.find(redundantstatuses[i].id).destroy
                        rescue
                            puts "Fail"
                        end
                    end
                end
        end
    end

    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>"

    PersonRecordStatus.by_person_record_id.key(person_id).each do |s|
        if s.status.blank?
            s.destroy
        end
    end
	
    last = nil
    RecordStatus.where(person_record_id: person_id).order(:created_at).each do |d|
	couch_status = PersonRecordStatus.find(d.person_record_status_id)
	if couch_status.blank?
		d.destroy
	else 
		last = d
	end
    end
    begin
	    last = PersonRecordStatus.find(last.person_record_status_id)
	    last.voided = false
	    last.save
    rescue
	   puts "Error #{person_id}"
    end


end

sql = "SELECT distinct person_record_id FROM person_record_status WHERE status IN('DC ACTIVE','DC COMPLETE') AND voided = 0 AND district_code ='#{SETTINGS['district_code']}' ORDER BY created_at DESC;"
#raise ActiveRecord::Base.connection.select_all(sql).inspect
ActiveRecord::Base.connection.select_all(sql).each_with_index do |pids,i|
	begin
		remove_redu_states(pids['person_record_id'])
		puts "#{i} records corrected" if i % 10 == 0
	rescue Exception => e
		puts "Error #{e.to_s}"
	end
end

