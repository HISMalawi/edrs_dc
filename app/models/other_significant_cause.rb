class OtherSignificantCause < ActiveRecord::Base
	after_commit :push_to_couchDB,:push_to_remote
	before_create :set_id
	self.table_name = "other_significant_causes"
	def person
		return Record.find(self.person_id)
	end
	def set_id
		self.other_significant_cause_id = SecureRandom.uuid if self.other_significant_cause_id.blank?
	end
    def push_to_couchDB
		data =  Pusher.database.get(self.id) rescue {}
		
		self.as_json.keys.each do |key|
			next if key == "_rev"
			next if key =="_deleted"
			if key == "other_significant_cause_id"
			 	data["_id"] = self.as_json[key]
			elsif key=="voided"
				data[key] = (self.as_json[key]==1? true : false)
			else
			 	data[key] = self.as_json[key]
			end
			if data["type"].nil?
				data["type"] = "OtherSignificantCause"
			end
		end
		
		return  Pusher.database.save_doc(data)
	end
	def push_to_remote
		data = self.as_json
		if data["type"].nil?
			data["type"] = "OtherSignificantCauseRecord"
		end
		return  RemotedPusher.push(data)
	end
end