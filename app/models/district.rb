require 'couchrest_model'

class District < CouchRest::Model::Base

  property :code, String
  property :name, String
  property :region, String
  
  timestamps!

  design do
      view :by__id
      view :by_name
      view :by_code
  end

  def insert_update_into_mysql
      fields  = self.keys.sort
      sql_record = DistrictRecord.where(district_id: self.id).first
      sql_record = DistrictRecord.new if sql_record.blank?
      fields.each do |field|
        next if field == "type"
        next if field == "_rev"
        next if field == "code"
        if field =="_id"
            sql_record["district_id"] = self[field]
        else
            sql_record[field] = self[field]
        end

      end
      sql_record.save
  end

end
