class BarcodeRecord < ActiveRecord::Base
	after_commit :push_to_remote,:push_to_couchDB
	before_create :set_id
	self.table_name = "barcodes"
	def person
		return Person.find(self.person_record_id)
	end
	def set_id
		self.barcode_id = SecureRandom.uuid if self.barcode_id.blank?
	end
	def push_to_couchDB
		data =  Pusher.database.get(self.id) rescue {}
		
		self.as_json.keys.each do |key|
			next if key == "_rev"
			next if key =="_deleted"
			if key == "barcode_id"
				data["_id"] = self.as_json[key]
			else
				data[key] = self.as_json[key]
			end
			if data["type"].nil?
				data["type"] = "Barcode"
			end
		end
		
		return  Pusher.database.save_doc(data)

	end

	def push_to_remote
		data = self.as_json
		if data["type"].nil?
			data["type"] = "BarcodeRecord"
		end
		return  RemotedPusher.push(data)
	end
end