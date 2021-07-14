class Barcode < CouchRest::Model::Base
	before_save :set_district_code
	after_save :insert_update_into_mysql
	after_create :insert_update_into_mysql
	property :person_record_id, String
	property :barcode, String
	property :assigned, String, :default => 'true'
	property :district_code, String
	property :creator, String
	timestamps!

	design do
    	view :by__id
    	view :by_barcode
    	view :by_assigned
    	filter :assigned_sync, "function(doc,req) {return req.query.assigned == 'true' }"
  end

  def set_district_code
    	self.district_code = (self.person.district_code rescue SETTINGS['district_code'])
  end

  def person
	    person = Record.find(self.person_record_id)
	    return person
  end

  def insert_update_into_mysql
      fields  = self.keys.sort
      sql_record = BarcodeRecord.where(person_record_id: self.person_record_id, barcode: self.barcode).first
      sql_record = BarcodeRecord.new if sql_record.blank?
      fields.each do |field|
        next if field == "type"
        next if field == "_rev"
        next if field == "created_at"
        next if field == "updated_at"
        next if field == "assigned"
        if field =="_id"
            sql_record["barcode_id"] = self[field]
        elsif self[field] == "barcode"
            sql_record[field] = "#{self[field].to_i}".squish
        else          
            sql_record[field] = self[field]
        end

      end
      sql_record.save
  end
end