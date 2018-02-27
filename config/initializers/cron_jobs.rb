if SETTINGS['site_type'].to_s != "facility"
    if (defined? PersonIdentifier.can_assign_den).nil?
       PersonIdentifier.can_assign_den = true
    end
    AssignDen.perform_in(3)
end
if Rails.env == 'development'
     SyncData.perform_in(60)
else
  	 SyncData.perform_in(900)
end

if Rails.env == 'development'
    UpdateSyncStatus.perform_in(90)
else
  	UpdateSyncStatus.perform_in(1000)
end
