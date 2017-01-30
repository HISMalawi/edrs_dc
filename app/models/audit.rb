require 'couchrest_model'

class Audit < CouchRest::Model::Base
  
  before_save :set_site_id, :set_site_type, :set_user_id

  property :record_id, String # Person/Audit...
  property :audit_type, String # Quality Control | Reprint | Audit
  property :level, String # Person | User
  property :reason, String
  property :user_id, String # User id
  property :site_id, String
  property :site_type, String  #FACILITY, DC, HQ
  property :change_log, [], :default => []
  property :voided, TrueClass, :default => false
  
  timestamps!

  design do
    view :by__id
    view :by_record_id
    view :by_record_id_and_audit_type
    view :by_record_id_and_reason
    view :by_audit_type
    view :by_level
    view :by_user_id
    view :by_site_id
    view :by_site_type
    view :by_voided
    view :by_created_at
    view :by_updated_at

    filter :facility_sync, "function(doc,req) {return req.query.site_id == doc.site_id}"

  end
  
  def set_user_id
    self.user_id = User.current_user.id rescue 'admin'
  end
  
  def set_site_id

    if CONFIG['site_type'] =="facility"

        self.site_id = CONFIG["facility_code"]

    else

        self.site_id = CONFIG["district_code"]

    end
  end  
  
  def set_site_type

     if CONFIG['site_type'] =="facility"

        self.site_type = "facility"

    else

         self.site_type = "DC"

    end
  end 
 
end
