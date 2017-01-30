class BurialReport < CouchRest::Model::Base

	 property :person_record_id, String 

	 property :cementry_authority_first_name, String

	 property :cementry_authority_last_name, String

	 property :cementry_name, String

	 property :district, String

	 property :ta, String

	 property :village, String

	 property :date_of_burial, String

	 property :date_report_signed, String

end
