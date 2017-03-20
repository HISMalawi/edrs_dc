config = CONFIG
if config['site_type']=='dc'
	sync_records = Sync.by_dc_unsynced.each
	count = 0
	sync_records.each do |sync|
		if sync.person.present?
			sync.dc_sync_status = true
			sync.record_status = sync.person.status
			sync.save
			count = count + 1
		end
	end
	puts "#{count} of #{sync_records.count} Synced"
else
	puts "Don't require this at Facility"
end