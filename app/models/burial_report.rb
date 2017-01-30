class BurialReport < CouchRest::Model::Base

	 property :person_record_id, String 

	 property :cemetery_authority_first_name, String

	 property :cemetery_authority_last_name, String

	 property :cemetery_name, String

	 property :district, String

	 property :ta, String

	 property :village, String

	 property :date_of_burial, String

	 property :date_report_signed, String

	 property :voided,  TrueClass, :default => false

	 timestamps!

	 design do

	 	view  :by_person_record_id

	 end

end
