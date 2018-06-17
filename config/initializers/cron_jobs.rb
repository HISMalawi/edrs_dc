if CronJobsTracker.first.blank?
	CronJobsTracker.new.save
end
AssignDen.perform_in(30)