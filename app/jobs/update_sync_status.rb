class UpdateSyncStatus
	include SuckerPunch::Job
  	workers 1
  	def perform
  		`rake edrs:update_sync_status`
  		if Rails.env == "development"
          SuckerPunch.logger.info "Sync update from Facilities Done"
        end

        if Rails.env == 'development'
        	UpdateSyncStatus.perform_in(60)
        else
  			UpdateSyncStatus.perform_in(900)
  		end
  	end
end