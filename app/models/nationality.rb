require 'couchrest_model'
class Nationality < CouchRest::Model::Base

  property :nationality, String

  design do
    view :by__id
    view :by_nationality
  end
  def insert_update_into_mysql
      fields  = self.keys.sort
      sql_record = NationalityRecord.where(nationality_id: self.id).first
      sql_record = NationalityRecord.new if sql_record.blank?
      fields.each do |field|
        next if field == "type"
        next if field == "_rev"
        if field =="_id"
            sql_record["nationality_id"] = self[field]
        else
            sql_record[field] = self[field]
        end

      end
      sql_record.save
  end
end
