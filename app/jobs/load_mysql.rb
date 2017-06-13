class LoadMysql
	include SuckerPunch::Job
  	workers 1
  	def perform
  		`rake edrs:build_mysql`
  		if Rails.env == "development"
          SuckerPunch.logger.info "Load MYSQL"
        end

        if Rails.env == 'development'
        	LoadMysql.perform_in(60)
        else
  			  LoadMysql.perform_in(900)
  		end
  	end
end