class SyncData
	include SuckerPunch::Job
  	workers 1
  	def perform

  		Kernel.system "bundle exec rake edrs:sync"

      sync_tracker = CronJobsTracker.first
      sync_tracker = CronJobsTracker.new if sync_tracker.blank?
      sync_tracker.time_last_synced = Time.now
      sync_tracker.save
      
  		if Rails.env == "development"
          SuckerPunch.logger.info "Sync Data"
      end

      if Rails.env == 'development'
        	SyncData.perform_in(60)
      else
  			SyncData.perform_in(300)
  		end
  	end
end