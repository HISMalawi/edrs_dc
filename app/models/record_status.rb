class RecordStatus < ActiveRecord::Base
	after_commit :push_to_couchDB, :push_to_remote
	before_create :set_id
	self.table_name = "person_record_status"
	def person
		return Record.find(self.person_record_id)
	end
	def set_id
		self.person_record_status_id = SecureRandom.uuid if self.person_record_status_id.blank?
	end
	def self.change_status(person, currentstatus,comment=nil, creator = nil)
		if creator.blank?
			creator = (UserModel.current_user.id rescue nil)
		end
		new_status = RecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => currentstatus,
                                  :comment => comment,
                                  :district_code => person.district_code,
                                  :voided => 0,
                                  :creator => (creator rescue nil),
                              	  :created_at => Time.now,
                              	  :updated_at => Time.now})

	    RecordStatus.where(person_record_id: person.id).order(:created_at).each do |s|
	        next if s === new_status
	        s.voided = 1
	        s.save
	    end
	end

	def push_to_remote
		data = self.as_json
		if data["type"].nil?
			data["type"] = "RecordStatus"
		end
		
		return  RemotedPusher.push(data)
	end
end

