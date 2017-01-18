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
      view :by_facility_type
      view :by_f_type
      view :by_district_id,
           :map=>"function(doc){
                    if(doc.type == 'HealthFacility'){
                        emit(doc.district_id,{name : doc.name, created_at : doc.created_at})
                    }
           }"
      view :by_zone
      view :by_latitude_and_longitude
  end
  
end
