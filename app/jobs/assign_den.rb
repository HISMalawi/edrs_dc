class AssignDen
  include SuckerPunch::Job
  workers 1

  def perform()
    queue = PersonRecordStatus.by_marked_for_approval.each
    job_interval = CONFIG['ben_assignment_interval']
    job_interval = 1.5 if job_interval.blank?
    job_interval = job_interval.to_f

    FileUtils.touch("#{Rails.root}/public/sentinel")

    if Rails.env = 'development' || queue.count > 0
      SuckerPunch.logger.info "Approving for #{queue.count} record(s)"
    end
    queue.each do |record|
        person = record.person
        status = PersonRecordStatus.by_person_recent_status.key(record.person_record_id.to_s).last

        status.update_attributes({:voided => true})

        PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => "DC APPROVED",
                                  :district_code => CONFIG['district_code'],
                                  :creator => record.creator})

        person.update_attributes({:approved =>"Yes",:approved_at=> (Time.now)})

        PersonIdentifier.assign_den(person, record.creator)

        Audit.create(record_id: record.id,
                       audit_type: "Audit",
                       user_id: record.creator,
                       level: "Person",
                       reason: "Approved record")

        #checkCreatedSync(record.id, "HQ OPEN", record.request_status)

        SuckerPunch.logger.info "#{record.id} => #{record.district_id_number}"
    end rescue (AssignDen.perform_in(job_interval))

    AssignDen.perform_in(job_interval)
  end
end
