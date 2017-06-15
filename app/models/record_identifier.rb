class RecordIdentifier < ActiveRecord::Base
	self.table_name = "person_identifier"
	def self.create_from_couch(identifier_record)
	  	 mysql_record = RecordIdentifier.new
        mysql_record.person_identifier_id = identifier_record.id
        mysql_record.person_record_id = identifier_record.person_record_id
        mysql_record.identifier_type = identifier_record.identifier_type
        mysql_record.identifier = identifier_record.identifier
        mysql_record.site_code = identifier_record.site_code
        mysql_record.den_sort_value = identifier_record.den_sort_value
        mysql_record.district_code = identifier_record.district_code
        mysql_record.creator = identifier_record.creator
        mysql_record['_rev'] = identifier_record.rev
        mysql_record.created_at = identifier_record.created_at
        mysql_record.updated_at = identifier_record.updated_at
        mysql_record.save rescue nil
	end
end
