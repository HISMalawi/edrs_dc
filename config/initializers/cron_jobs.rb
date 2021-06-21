if CronJobsTracker.first.blank?
	CronJobsTracker.new.save
end

PersonIdentifier.can_assign_den = true
# AssignDen.perform_in(30)
