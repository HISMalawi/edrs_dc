class PersonRecordStatus < CouchRest::Model::Base

	before_save :set_district_code,:set_facility_code

	property :person_record_id, String
	property :status, String #DC Active|HQ Active|HQ Approved|Printed|Reprinted...
	property :prev_status, String
	property :district_code, String
	property :facility_code, String
	property :voided, TrueClass, :default => false
	property :reprint, TrueClass, :default => false
	property :creator, String

	timestamps!

	design do 
		view :by_status
		view :by_distrit_code
		view :by_voided
		view :by_creator
		view :by_created_at
		view :by_person_record_id
		view :by_prev_status
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
	    view :by_marked_for_approval,
	    		:map =>"function(doc){
		    			   if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false && doc['status']=='MARKED APPROVAL'){
		                    	emit(doc['status'], 1);
		                  	}
	    			   }"
	    view :by_amend_or_reprint,
	    		:map =>"function(doc){
		    			   if (doc['type'] == 'PersonRecordStatus' && doc['reprint'] == true){
		                    	emit(doc['status'], 1);
		                  	}
	    			   }"
	    filter :district_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"
	    filter :facility_sync, "function(doc,req) {return req.query.facility_code == doc.facility_code}"

	end

	def set_district_code
		self.district_code = self.person.district_code
	end

	def set_facility_code
		self.facility_code = self.person.facility_code
	end

	def person
	    return Person.find(self.person_record_id)    	
	end

	def self.change_status(person,currentstatus)
		status = PersonRecordStatus.by_person_recent_status.key(person.id).last
		if status.present?
			status.update_attributes({:voided => true})
			PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => currentstatus,
                                  :prev_status => status.status,
                                  :district_code => person.district_code,
                                  :creator => (User.current_user.id rescue nil)})
		else
			PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => currentstatus,
                                  :prev_status => nil,
                                  :district_code => person.district_code,
                                  :creator => (User.current_user.id rescue nil)})
		end
		
	end
end
