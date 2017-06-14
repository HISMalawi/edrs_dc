class LoadMysql
	include SuckerPunch::Job
  	workers 1
  	def perform
  		  `rake edrs:build_mysql`
  		  if Rails.env == "development"
          SuckerPunch.logger.info "Load MYSQL"
        end
        
        if Rails.env == 'development'
        	LoadMysql.perform_in(600)
        else
          midnight = (Date.today).to_date.strftime("%Y-%m-%d 23:59:59").to_time
          now = Time.now
          diff = (midnight  - now).to_i
  			  LoadMysql.perform_in(diff)
  		  end
  	end
end