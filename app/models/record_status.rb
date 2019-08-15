class RecordStatus < ActiveRecord::Base
	after_commit :push_to_couch
	self.table_name = "person_record_status"
	def person
		return Person.find(self.person_record_id)
	end

	def self.change_status(person, currentstatus,comment=nil, creator = nil)
		new_status = RecordStatus.create({
								  :person_record_status_id => SecureRandom.uuid,
                                  :person_record_id => person.id.to_s,
                                  :status => currentstatus,
                                  :comment => comment,
                                  :district_code => person.district_code,
                                  :voided => false,
                                  :creator => nil,
                              	  :created_at => Time.now,
                              	  :updated_at => Time.now})

	    RecordStatus.where(person_record_id: person.id).each.sort_by{|d| d.created_at}.each do |s|
	        next if s === new_status
	        s.voided = true
	        s.save
	    end
	end

	def push_to_couch
		new_status = PersonRecordStatus.find(self.person_record_status_id) rescue nil
		new_status = PersonRecordStatus.new if new_status.blank?
		new_status.id = self.person_record_status_id
        new_status.person_record_id = self.person_record_id.to_s
        new_status.status = self.status
        new_status.comment = self.comment
        new_status.voided = self.voided
        new_status.district_code = self.district_code
        new_status.creator = self.creator
        new_status.created_at = self.created_at
        new_status.updated_at = self.updated_at
        new_status.save
	end
end
