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