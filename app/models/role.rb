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

end
