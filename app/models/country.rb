class Country < CouchRest::Model::Base
	property :name, String
	property :iso, String
	property :numcode, String
	property :phonecode, String
	timestamps!
	design do
	    view :by__id
	    view :by_name
	    view :by_country,
	    	 :map => "function(doc) {
                  if ((doc['type'] == 'Country')) {
                    emit(doc['name'], 1);
                  }
                }"
      	view :by_iso
	end

	def insert_update_into_mysql
      fields  = self.keys.sort
      sql_record = CountryRecord.where(country_id: self.id).first
      sql_record = CountryRecord.new if sql_record.blank?
      fields.each do |field|
        next if field == "type"
        next if field == "_rev"
        next if field == "code"
        if field =="_id"
            sql_record["country_id"] = self[field]
        else
            sql_record[field] = self[field]
        end

      end
      sql_record.save
  end
end
