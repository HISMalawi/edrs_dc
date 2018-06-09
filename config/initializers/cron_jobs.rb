if CronJobsTracker.first.blank?
	CronJobsTracker.new.save
end
