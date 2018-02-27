class CronJobsTracker < CouchRest::Model::Base
  property :time_last_synced, Time
  property :time_sync_scheduled, Time
  property :time_last_updated_sync, Time
  property :time_updated_sync_scheduled, Time
  property :time_last_assigned_den, Time
  timestamps!
  design do
    view :by__id
  end

end
