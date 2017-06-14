if (defined? PersonIdentifier.can_assign_den).nil?
	PersonIdentifier.can_assign_den = true
end
if CONFIG['site_type'].to_s != "facility"
	AssignDen.perform_in(3)
end
if Rails.env == 'development'
     SyncData.perform_in(60)
else
  	 SyncData.perform_in(900)
end

if Rails.env == 'development'
    UpdateSyncStatus.perform_in(10)
else
  	UpdateSyncStatus.perform_in(1000)
end

if Rails.env == 'development'
    LoadMysql.perform_in(600)
else
    midnight = (Date.today).to_date.strftime("%Y-%m-%d 23:59:59").to_time
    now = Time.now
    diff = (midnight  - now).to_i
  	LoadMysql.perform_in(diff)
end