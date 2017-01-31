class BurialReport < CouchRest::Model::Base

	 property :person_record_id, String 

	 property :cemetery_authority_first_name, String

	 property :cemetery_authority_last_name, String

	 property :cemetery_name, String

	 property :district, String

	 property :ta, String

	 property :village, String

	 property :date_of_burial, Time

	 property :date_report_signed, Time

	 property :date_report_given, Time

	 property :voided,  TrueClass, :default => false

	 timestamps!

	 design do

	 	view  :by_person_record_id

	 end

end
