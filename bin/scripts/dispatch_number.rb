i = 1 
CauseOfDeathDispatch.by_district_code.key(SETTINGS['district_code']).sort_by{|c| c.created_at}.each do |d|
	d.dispatch_number = i 
	d.save
	i = i + 1
end