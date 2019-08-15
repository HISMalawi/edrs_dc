class AssignDen
  include SuckerPunch::Job
  workers 1

  def perform()
    queue = RecordStatus.where("status = 'MARKED APPROVAL' AND voided = 0 ").each
    job_interval = SETTINGS['den_assignment_interval']
    job_interval = 1.5 if job_interval.blank?
    job_interval = job_interval.to_f

    FileUtils.touch("#{Rails.root}/public/sentinel")

    if Rails.env == 'development' || queue.count > 0
      #SuckerPunch.logger.info "Approving for #{queue.count} record(s)"
    end

    queue.each do |record|
        person = record.person

        if person.den == "XXXXXXXX"
          if SETTINGS['site_type'] == "remote"
                next if SETTINGS['exclude'].split(",").include?(District.find(person.district_code).name)
          end

          PersonIdentifier.assign_den(person, record.creator)

          #checkCreatedSync(record.id, "HQ OPEN", record.request_status)
          if Rails.env == 'development'
            SuckerPunch.logger.info "#{record.id} => #{record.district_id_number}"
          end
        else
          RecordStatus.change_status(person, "HQ ACTIVE", "Approved at HQ",(record.creator rescue  nil))          
        end
    end rescue (AssignDen.perform_in(job_interval))
  end
end
