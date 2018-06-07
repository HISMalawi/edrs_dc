class UpdateSyncStatus
	include SuckerPunch::Job
  	workers 1
  	def perform
  		Kernel.system "bundle exec rake edrs:update_sync_status"
      
      update_sync_tracker = CronJobsTracker.first
      update_sync_tracker = CronJobsTracker.new if update_sync_tracker.blank?
      update_sync_tracker.time_last_updated_sync = Time.now
      update_sync_tracker.save

  		if Rails.env == "development"
          SuckerPunch.logger.info "Sync update from Facilities Done"
        end

        if Rails.env == 'development'
        	UpdateSyncStatus.perform_in(1200)
        else
    			UpdateSyncStatus.perform_in(9000)
    		end
  	end
end