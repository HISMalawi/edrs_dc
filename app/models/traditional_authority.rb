require 'couchrest_model'

class TraditionalAuthority < CouchRest::Model::Base
  property :district_id, String
  property :name, String
  
  timestamps!
 
  design do
      view :by__id
      view :by_district_id,
      	   :map => "function(doc){

      	   			if(doc.type=='TraditionalAuthority'){

      	   				emit(doc.district_id, {name : doc.name})
      	   			}
      	  	      }"
      view :by_name
      view :by_district_id_and_name

  end

  def insert_update_into_mysql
      fields  = self.keys.sort
      sql_record = TA.where(traditional_authority_id: self.id).first
      sql_record = TA.new if sql_record.blank?
      fields.each do |field|
        next if field == "type"
        next if field == "_rev"
        next if field == "code"
        if field =="_id"
            sql_record["traditional_authority_id"] = self[field]
        else
            sql_record[field] = self[field]
        end

      end
      sql_record.save
  end
  
end
