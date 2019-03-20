require 'couchrest_model'

class HealthFacility < CouchRest::Model::Base
 
  property :district_id,String
  property :facility_code, String
  property :name, String
  property :zone,String
  property :facility_type, String
  property :f_type, String
  property :latitude,String
  property :longitude,String
  
  timestamps!
 
  design do
      view :by__id
      view :by_name
      view :by_facility_code
      view :by_district_id,
           :map=>"function(doc){
                    if(doc.type == 'HealthFacility' && doc.name.length > 0){
                        emit(doc.district_id,{name : doc.name, created_at : doc.created_at})
                    }
           }"
      view :by_district_id_and_name
      view :by_latitude_and_longitude
  end

  def insert_update_into_mysql
      fields  = self.keys.sort
      sql_record = Facility.where(health_facility_id: self.id).first
      sql_record = Facility.new if sql_record.blank?
      fields.each do |field|
        next if field == "type"
        next if field == "_rev"
        if field =="_id"
            sql_record["health_facility_id"] = self[field]
        else
            sql_record[field] = self[field]
        end

      end
      sql_record.save
  end
  
end
