class AssignDen
  include SuckerPunch::Job
  workers 1

  def perform()
    queue = PersonRecordStatus.by_marked_for_approval.each
    job_interval = CONFIG['den_assignment_interval']
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

        person.approved = "Yes"
        person.approved_at = Time.now

        person.save

        PersonIdentifier.assign_den(person, record.creator)

        Audit.create(record_id: record.person_record_id,
                       audit_type: "Audit",
                       user_id: record.creator,
                       level: "Person",
                       reason: "Approved record")

        stat = Statistic.by_person_record_id.key(person.id).first

        if stat.present?
           stat.update_attributes({:date_doc_approved => record.person.approved_at.to_time})
        else
          stat = Statistic.new
          stat.person_record_id = person.id
          stat.date_doc_created = person.created_at.to_time
          stat.date_doc_approved = person.approved_at.to_time
          stat.save
        end

        #checkCreatedSync(record.id, "HQ OPEN", record.request_status)
        if Rails.env = 'development'
          SuckerPunch.logger.info "#{record.id} => #{record.district_id_number}"
        end
    end rescue (AssignDen.perform_in(job_interval))

    AssignDen.perform_in(job_interval)
  end
end
