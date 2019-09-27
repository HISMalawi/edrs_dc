require 'couchrest_model'

class Online < CouchRest::Model::Base
  before_save :set_id_and_code
  def set_id_and_code
    self['_id']= "#{SETTINGS['district_code']}SYNC" if self['_id'].blank?
    self['district_code']= "#{SETTINGS['district_code']}"
  end
  property :district_code, String
  property :ip, String
  property :port, String
  property :online, TrueClass, :default => false
  property :time_seen, String
  
  timestamps!

  design do
      view :by__id
  end

end
