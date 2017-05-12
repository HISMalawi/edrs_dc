class SyncData
	include SuckerPunch::Job
  	workers 1
  	def perform
  		`rake edrs:sync`
  		if Rails.env == "development"
          SuckerPunch.logger.info "Sync from HQ"
        end

        if Rails.env == 'development'
        	SyncData.perform_in(30)
        else
  			SyncData.perform_in(900)
  		end
  	end
end