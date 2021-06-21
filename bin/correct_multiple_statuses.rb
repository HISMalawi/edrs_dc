def remove_redu_states(person_id)
    #puts person_id
    state =  ["DC ACTIVE","DC COMPLETE","HQ ACTIVE","HQ INCOMPLETE","HQ CONFLICT","HQ CAN REJECT","HQ REJECTED","HQ COMPLETE","HQ CAN PRINT", "HQ PRINTED","DC PRINTED","HQ DISPATCHED"]
    statuses = PersonRecordStatus.by_person_record_id.key(person_id).each
    statuses.each do |st|
        st.insert_update_into_mysql
    end
    
    uniqstatus = statuses.collect{|d| d.status}.uniq

    uniqstatus.each do |us|
        redundantstatuses = PersonRecordStatus.by_person_record_id.key(person_id).each.reject{|s| s.status != us}.sort_by{|s| s.created_at}

        puts "destroying multiple #{us}"
        redundantstatuses.each_with_index do |red, i|
                if i != 0
                    begin
                        redundantstatuses[i].destroy
                    rescue
                        puts "Error : #{redundantstatuses[i].id}"
                        puts "Retry"
                        begin
                            RecordStatus.find(redundantstatuses[i].id).destroy
                            PersonRecordStatus.find(redundantstatuses[i].id).destroy
                            
                        rescue
                            puts "Fail"
                        end
                    end
                else
                    redundantstatuses[i].insert_update_into_mysql
                end
        end
    end

    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>"

    PersonRecordStatus.by_person_record_id.key(person_id).each do |s|
        if s.status.blank?
            s.destroy
        end
    end
	
    last = 0

    RecordStatus.where(person_record_id: person_id).order(:created_at).each do |d|
        person_status = PersonRecordStatus.by_person_recent_status.key(d.person_record_id).last
        if state.find_index(d.status).to_i > last
            last = state.find_index(d.status).to_i
        end

        if person_status.present? && state.find_index(d.status).to_i < state.find_index(person_status.status).to_i
                d.voided = 1 
                d.save
        end
        couch_status = PersonRecordStatus.find(d.person_record_status_id)
        if couch_status.blank?
            d.destroy
        end
    end

    RecordStatus.where(person_record_id: person_id, voided: 0).each do |d|
        if last != state.find_index(d.status).to_i
                couch_status = PersonRecordStatus.find(d.person_record_status_id)
                couch_status.voided = true
                couch_status.save
                d.voided = 1 
                d.save
        else
            couch_status = PersonRecordStatus.find(d.person_record_status_id)
            couch_status.voided = false
            couch_status.save
            d.voided = 0 
            d.save            
        end
    end
    RecordStatus.where(person_record_id: person_id,status: state[last] ).each do |d|
        puts d.status
        couch_status = PersonRecordStatus.find(d.person_record_status_id)
        couch_status.voided = false
        couch_status.save
        d.voided = 0 
        d.save  
    end

end


sql = "SELECT distinct person_record_id FROM person_record_status WHERE status IN('DC ACTIVE','DC COMPLETE','HQ ACTIVE', 'HQ COMPLETE', 'HQ CAN PRINT') AND voided = 0 AND district_code ='#{SETTINGS['district_code']}' ORDER BY created_at DESC;"
#raise ActiveRecord::Base.connection.select_all(sql).inspect
ActiveRecord::Base.connection.select_all(sql).each_with_index do |pids,i|
	begin
		remove_redu_states(pids['person_record_id'])
		puts "#{i} records corrected" if i % 10 == 0
	rescue Exception => e
		puts "Error #{e.to_s}"
	end
end

