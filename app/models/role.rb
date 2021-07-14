class Role < CouchRest::Model::Base

  property :role, String
  property :level, String
  property :activities, []

  design do
    view :all
    view :by__id
    view :by_role
    view :by_level
    view :by_level_and_role

  end

  def insert_update_into_mysql
      fields  = self.keys.sort
      sql_record = RoleRecord.where(role_id: self.id).first
      sql_record = RoleRecord.new if sql_record.blank?
      fields.each do |field|
        next if field == "type"
        next if field == "_rev"
        if field =="_id"
            sql_record["role_id"] = self[field]
        elsif field =="activities"
            sql_record["activities"] = self[field].join("|")
        else
            sql_record[field] = self[field]
        end
      end
      sql_record.save
  end

end
