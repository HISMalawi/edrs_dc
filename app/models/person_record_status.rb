class PersonRecordStatus < CouchRest::Model::Base

	before_save :set_district_code,:set_facility_code, :set_registration_type
	#after_create :insert_in_mysql

	property :person_record_id, String
	property :status, String #DC Active|HQ Active|HQ Approved|Printed|Reprinted...
	property :prev_status, String
	property :district_code, String
	property :facility_code, String
	property :voided, TrueClass, :default => false
	property :reprint, TrueClass, :default => false
	property :registration_type, String
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
		view :by_prev_status_and_status
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
	     view :by_district_code_and_record_status,
	    			 :map => "function(doc) {
	                  if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false) {

	                    	emit([doc['district_code'],doc['status']], 1);
	                  }
	                }"
	    view :by_marked_for_approval,
	    		:map =>"function(doc){
		    			   if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false && doc['status']=='MARKED APPROVAL'){
		                    	emit(doc['status'], 1);
		                  	}
	    			   }"
	    view :by_marked_for_hq_approval,
	    		:map => "function(doc){
	    					 if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false && doc['status']=='MARKED HQ APPROVAL'){
		                    	emit(doc['status'], 1);
		                  	}
	    				}"	
	    view :by_amend_or_reprint,
	    		:map =>"function(doc){
		    			   if (doc['type'] == 'PersonRecordStatus' && doc['reprint'] == true){
		                    	emit(doc['status'], 1);
		                  	}
	    			   }"
	    view :by_status_and_created_at
	    view :by_district_code_and_status_and_created_at
	    view :by_reprint_date,
	    	  :map =>"function(doc){
		    			   if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false && doc['reprint']==true){
		                    	emit(doc['created_at'], 1);
		                  	}
	    			   }"	
	    view :by_status_and_time,
	    	  :map =>"function(doc){
		    			   if (doc['type'] == 'PersonRecordStatus'){
		                    	emit(doc['status']+'_'+doc['created_at'], 1);
		                  	}
	    			   }"
	    view :registration_type_and_recent_status,
	    		:map =>"function(doc){
		    			   if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false){
		                    	emit([doc['registration_type'],doc['status']], 1);
		                  	}
	    			   }"

	    filter :district_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"
	    filter :facility_sync, "function(doc,req) {return req.query.facility_code == doc.facility_code}"
	    filter :stats_sync, "function(doc,req) {return doc.district_code != null}"

	end

	def set_district_code
		self.district_code = self.person.district_code
	end

	def set_facility_code
		self.facility_code = self.person.facility_code
	end

	def set_registration_type
		self.registration_type = self.person.registration_type
	end

	def person
	    return Person.find(self.person_record_id)    	
	end

	def self.change_status(person,currentstatus)
		status = PersonRecordStatus.by_person_recent_status.key(person.id).last
		if status.present?
			status.update_attributes({:voided => true})
			self.update_status_to_mysql(status)
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

	def insert_in_mysql
		query = "INSERT INTO person_record_status(
				  		person_record_status_id,
				  		person_record_id,
				  		status,
				  		prev_status,
				  		district_code,
				  		facility_code,
				  		registration_type,
				  		creator,
				  		updated_at,
				  		created_at) VALUES (
				  		'#{self.id}',
				  		'#{self.person_record_id}',
				  		'#{self.status}',
				  		'#{(self.prev_status rescue 'NULL')}',
				  		'#{self.district_code}',
				  		'#{self.facility_code rescue 'NULL'}',
				  		'#{self.registration_type}',
				  		'#{self.creator}',
				  		'#{self.updated_at}',
				  		'#{self.created_at}')"

      	SimpleSQL.query_exec(query)
	end
	def self.update_status_to_mysql(status)
		query = "UPDATE person_record_status SET 
				  		person_record_id = '#{status.person_record_id}',
				  		status = '#{status.status}',
				  		prev_status = '#{status.prev_status}',
				  		voided = '#{status.voided}',
				  		updated_at = '#{status.updated_at}' 
				  		WHERE person_record_status_id = '#{status.id}'"

      	SimpleSQL.query_exec(query)
	end
end
