class Statistic < CouchRest::Model::Base
	before_save :set_district_code
	property :person_record_id,String
	property :date_doc_created, Time
	property :date_doc_approved, Time
	property :district_code, String
	design do
		view :by_person_record_id
		view :by_date_doc_created
		view :by_date_doc_approved
		view :by_district_code_and_date_doc_created
		view :by_turn_around_time,
			  :map =>"function(doc){
		    			   if (doc['type'] == 'Statistic' && doc['date_doc_approved'] != null){
		    			   		var date_created = new Date(doc.date_doc_created);
		    			   		var date_approved = new Date(doc.date_doc_approved);
		    			   		var seconds_difference = (date_approved.getTime()-date_created.getTime())/1000;
		                    	emit(seconds_difference, 1);
		                  	}
	    			   }"
	   	view :by_district_code_and_turn_around_time,
			  :map =>"function(doc){
		    			   if (doc['type'] == 'Statistic' && doc['date_doc_approved'] != null){
		    			   		var date_created = new Date(doc.date_doc_created);
		    			   		var date_approved = new Date(doc.date_doc_approved);
		    			   		var seconds_difference = (date_approved.getTime()-date_created.getTime())/1000;
		                    	emit([doc['district_code'],seconds_difference], 1);
		                  	}
	    			   }"
		filter :stats_sync, "function(doc,req) {return doc.district_code != null}"
	end

	def person
		return Person.find(self.person_record_id)
	end

	def set_district_code
		self.district_code = self.person.district_code
	end
end
