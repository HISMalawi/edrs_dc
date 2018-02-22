class SyncData
	include SuckerPunch::Job
  	workers 1
  	def perform
  		Kernel.system "bundle exec rake edrs:sync"
  		if Rails.env == "development"
          SuckerPunch.logger.info "Sync Data"
      end

      if Rails.env == 'development'
        	SyncData.perform_in(60)
      else
  			SyncData.perform_in(900)
  		end
  	end
end