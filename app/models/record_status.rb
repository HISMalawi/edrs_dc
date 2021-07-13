class RecordStatus < ActiveRecord::Base
	after_commit  :push_to_remote
	before_create :set_id
	self.table_name = "person_record_status"
	def person
		return Person.find(self.person_record_id)
	end
	def set_id
		self.person_record_status_id = SecureRandom.uuid if self.person_record_status_id.blank?
	end
	def self.change_status(person, currentstatus,comment=nil, creator = nil)
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

	def push_to_couchDB
		data =  Pusher.database.get(self.id) rescue {}
		
		self.as_json.keys.each do |key|
			next if key == "_rev"
			next if key =="_deleted"
			if key == "person_record_status_id"
			 	data["_id"] = self.as_json[key]
			elsif key=="voided"
				data[key] = (self.as_json[key]==1? true : false)
			else
			 	data[key] = self.as_json[key]
			end
			if data["type"].nil?
				data["type"] = "PersonRecordStatus"
			end
		end
		
		return  Pusher.database.save_doc(data)

	end

	def push_to_remote
		return  Pusher2.push(self.as_json)

	end
end

