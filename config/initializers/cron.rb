AssignDen.perform_in(3)
if Rails.env == 'development'
     SyncData.perform_in(30)
else
  	 SyncData.perform_in(900)
end

if Rails.env == 'development'
    UpdateSyncStatus.perform_in(10)
else
  	UpdateSyncStatus.perform_in(1000)
end