class PersonRecordStatus < CouchRest::Model::Base

	before_save :set_district_code

	property :person_record_id, String

	property :status, String #DC Active|HQ Active|HQ Approved|Printed|Reprinted...

	property :district_code, String

	property :voided, TrueClass, :default => false

	property :creator, String

	timestamps!

	design do 

		view :by_status

		view :by_distrit_code

		view :by_voided

		view :by_creator

		view :by_created_at

		view :by_person_record_id

	    view :by_person_recent_status,
				 :map => "function(doc) {
	                  if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false) {

	                    	emit(doc['person_record_id'], 1);
	                  }
	                }"
	    view :by_person_record_id_recent_status,
				 :map => "function(doc) {
	                  if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false) {

	                    	emit([doc['person_record_id'],doc['status']], 1);
	                  }
	                }"

		view :by_record_status,
	         	 :map => "function(doc) {
	                  if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false) {

	                    	emit(doc['status'], 1);
	                  }
	                }"

	        filter :district_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"

		end

		def set_district_code

			self.district_code = CONFIG["district_code"]
			
		end

		def person

	    	return Person.find(self.person_record_id)
	    	
	    end
end
