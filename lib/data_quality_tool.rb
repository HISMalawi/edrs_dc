
class DataQualityTool
  def self.deduplicate_records
    #Get all children records
    start_time = Time.now
    duplicate_count = 0
    records = Child.all.each

    (records || []).each do |record|
      #go through all records skipping those that are printed,approved, closed or voided

      next if (record.record_status.to_s.strip.downcase == "printed" || ['APPROVED', 'CLOSED', 'VOIDED'].include?(record.request_status.to_s.strip))

      #for each record, check if a similar one exists
      check = Child.by_child_demographics.keys([[record.first_name_code, record.last_name_code,record.gender,record.birthdate,record.mother.first_name_code,record.mother.last_name_code]]).each
        if check.count > 1
          #Record all duplicates

          (check || []).each do  |duplicate|

            next if duplicate.id == record.id
            if check_for_existence(record.id, duplicate.id)

              record_duplicate = Auditing.new
              record_duplicate.record_id = record.id
              record_duplicate.audit_type = "DEDUPLICATION"
              record_duplicate.reason = "Potential duplicate with #{duplicate.id}"
              record_duplicate.save

              record.update_attributes(:record_status => "POTENTIAL DUPLICATE")

              duplicate_count +=1
            end
          end
        end
    end

    end_time = Time.now

    summary = "Start Time :: #{start_time} | End Time :: #{end_time} | Number of Duplicates :: #{duplicate_count} | Records Checked :: #{records.count}"

    Auditing.create( :audit_type => 'DE-DUPLICATION PROCESS', :reason => summary)
  end

  def self.check_for_existence(origin, suspected)
    #Check if record of duplicate already exists before creating one
     keys = [origin, suspected]

     (keys || []).each do |record|
       origin_audits = Auditing.by_record_id.keys([record]).each
       (origin_audits || []).each do |audit|
         next if audit.audit_type != "DEDUPLICATION"

         if audit.reason == "Potential duplicate with #{keys[(keys.index(record) == 0 ? 1 : 0)]}"
           return false
         end
       end
     end
      return true
  end
end