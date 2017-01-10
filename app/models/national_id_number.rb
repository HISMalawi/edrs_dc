require 'couchrest_model'

class NationalIdNumber < CouchRest::Model::Base

  use_database "local"

  before_save      EncryptionWrapper.new("facility_serial_number_value")
  after_save       EncryptionWrapper.new("facility_serial_number_value")
  after_initialize EncryptionWrapper.new("facility_serial_number_value")

  before_save      EncryptionWrapper.new("facility_serial_number")
  after_save       EncryptionWrapper.new("facility_serial_number")
  after_initialize EncryptionWrapper.new("facility_serial_number")

  before_save      EncryptionWrapper.new("district_id")
  after_save       EncryptionWrapper.new("district_id")
  after_initialize EncryptionWrapper.new("district_id")

  property :facility_serial_number_value, String
  property :facility_serial_number, String
  property :district_id, String

  timestamps!

  design do
    view :by_district_id,
         :map => "function(doc) {
                  if ((doc['type'] == 'NationalIdNumber')) {
                    emit(doc['district_id'], 1);
                  }
                }"
  end

end
