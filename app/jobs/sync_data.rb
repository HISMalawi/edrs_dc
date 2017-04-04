class SyncData
	include SuckerPunch::Job
  	workers 1
  	def perform
  		`bundle exec rake edrs:sync`
  		if Rails.env = "development"
          SuckerPunch.logger.info "Sync from HQ"
        end
  		SyncData.perform_in(900)
  	end
end