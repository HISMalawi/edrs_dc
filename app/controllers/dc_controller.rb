class DcController < ApplicationController

	before_filter :facility_info

	before_filter :check_user_level_and_site

	def index

	  @facility = facility

      @district = district

      @section = "Home"

      @portal_link = (UserAccess.by_user_id.key(User.current_user.id).last.portal_link rescue nil)
      
      render :layout => "landing"
		
	end

	def check_completeness

		person = Person.find(params[:id])

		if record_complete?(person)
				PersonRecordStatus.change_status(person, "DC COMPLETE","Marked as complete")
				unlock_users_record(person)
				redirect_to "#{params[:next_url].to_s}"
		else
				PersonRecordStatus.change_status(person, "DC INCOMPLETE", "System marked as incomplete")
				unlock_users_record(person)
				redirect_to "/people/view/#{params[:id]}?next_url=#{params[:next_url]}&topic=Completeness Check&error=Record not complete"
		end
		
	end

	def cause_of_death_dispatch
		@section = "CCU Dispatch"		
	end

	def dispatch_barcodes
		cause_of_death_dispatch = CauseOfDeathDispatch.create({dispatch: params[:barcodes]})
		flash[:notice] = "CCU Dispatch Saved"
		render :text => "ok"
	end

	def manage_ccu_dispatch
		@section = "Manage CCU Dispatch"
		@next_url = "/"
	end

	def view_ccu_dispatch
		@section = "CCU Dispatch"
	end

	def ccu_dispatches
		render :text => CauseOfDeathDispatch.by_created_at.page(params[:page]).per(20).each.to_json
	end

	def manage_cases
		@section = "Manage Cases"

		render :layout => "landing"
		
	end

	def special_cases

		@section = "Special Cases"

		render :layout => "landing"
		
	end

	def approve_cases

		@section ="Approve Cases"

		@statuses = ["DC COMPLETE"]

		@next_url = "/dc/approve_cases"

		render :template =>"/people/view"
	
	end


	def approve_record
		person = Person.find(params[:id])
		PersonRecordStatus.change_status(person, "MARKED APPROVAL")
	    check_den_assignment
		unlock_users_record(person)
		render :text => {marked: true}.to_json	
	end

	def check_approval_status
		den = PersonIdentifier.by_person_record_id_and_identifier_type.key([params[:id], "DEATH ENTRY NUMBER"]).first
		if den.present?
			render :text => {assigned: true}.to_json
		else
			render :text => {assigned: false}.to_json
		end
	end

	def add_rejection_comment

		render :layout =>"touch"
	end

	def add_reaprove_comment
		@action ="/reaprove_record"
		@section = "Reaprove Comment"
		render :layout =>"plain_with_header"
	end

	def reaprove_record
		person = Person.find(params[:id])
		PersonRecordStatus.change_status(person, "DC REAPPROVED",params[:reason])
		unlock_users_record(person)
		redirect_to params[:next_url]
	end

	def reject_record
			person = Person.find(params[:id])
			PersonRecordStatus.change_status(person, "DC REJECTED",params[:reason])	
			unlock_users_record(person)		
			Audit.create({
							:record_id => params[:id].to_s    , 
							:audit_type=>"DC REJECTED",
							:level => "Person",
							:reason => params[:reason]})

			redirect_to "#{params[:next_url].to_s}"


	end

	def add_pending_comment

		@action ="/mark_as_pending"
		render :layout => "touch"
		
	end
	
	def mark_as_pending
		person = Person.find(params[:id])
		PersonRecordStatus.change_status(person, "DC INCOMPLETE","Marked as pending : #{params[:reason]}")
		unlock_users_record(person)
		Audit.create({
							:record_id => params[:id].to_s    , 
							:audit_type=>"DC INCOMPLETE",
							:level => "Person",
							:reason => "Marked as pending : #{params[:reason]}"})

		redirect_to "#{params[:next_url].to_s}"

		
	end

	def  approved_cases

		@section ="Approved Cases"

		@statuses = ["HQ ACTIVE"]

		@next_url = "/dc/approved_cases"

		@den = true 

		render :template =>"/people/view"
		
	end

	def rejected_cases

		@section = "Rejected Cases"

		@statuses = ["HQ REJECTED"]

		@next_url = "/dc/rejected_cases"

		@den = true 

		render :template =>"/people/view"
		
	end
	def voided

		@section = "voided Records"

		@statuses = ["HQ VOIDED"]

		@next_url = "/dc/voided"

		render :template =>"/people/view"
		
	end

	def closed

		@section = "Printed Records"

		@statuses = ["HQ PRINTED"]

		@next_url = "/dc/closed"

		@den = true 

		render :template =>"/people/view"
		
	end

	def dispatched

		@section = "Dispatched"

		@statuses = ["HQ DISPATCHED"]

		@next_url = "/dc/dispatched"

		@den = true 

		render :template =>"/people/view"
		
	end

	def pending_cases
		
		@section = "Pending Record"

		@statuses = ["DC INCOMPLETE", "DC REJECTED"]

		@next_url = "/dc/pending_cases"

		render :template =>"/people/view"

	end

	def manage_duplicates
		@section = "Manage Duplicates"
		render :layout => "landing"	
	end

	def potential_duplicates
		@section = "Potential Duplicate"
		@statuses = ["DC POTENTIAL DUPLICATE"]
		@next_url = "/dc/potential_duplicates"
		@duplicate = true
		render :template =>"/people/view"
	end

	def exact_duplicates
		@section = "Exact Duplicate"
		@statuses = ["DC EXACT DUPLICATE"]
		@next_url = "/dc/exact_duplicates"
		@duplicate = true
		render :template =>"/people/view"
	end

	def confirmed_duplicated
		@section = "Confimed Duplicate"
		@statuses = ["DC DUPLICATE"]
		@next_url = "/dc/confirmed_duplicated"
		@duplicate = true
		render :template =>"/people/view"
	end


	def show_duplicate

		@person = Person.find(params[:id])

		@status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last

	    @person_place_details = place_details(@person)

	    @existing_record = []

	    @existing_ids = ""
	    @duplicates_audit = Audit.by_record_id_and_audit_type.key([@person.id.to_s, "POTENTIAL DUPLICATE"]).first
	    @statuses = []
	    @duplicates_audit.change_log.each do |log|
	    	unless  log['duplicates'].blank?
	    		@existing_ids = log['duplicates']
	    		ids = log['duplicates'].split("|")
	    		ids.each do |id|
	    			 @existing_record << id
	    			 @statuses << PersonRecordStatus.by_person_recent_status.key(id).last.status
	    		end
	    	end
	    end

	    @statuses = @statuses.join("|")
	   
	    @section = "Resolve Duplicate"
	end

	def confirm_record_not_duplicate_comment

		@section = "Confirm record not Duplicate"

		render :layout =>"plain_with_header"
		
	end

	def confirm_not_duplicate
		person = Person.find(params[:id])
		PersonRecordStatus.change_status(person, "MARKED APPROVAL",params[:comment])
		check_den_assignment

		unlock_users_record(person)
		Audit.user = params[:user_id].to_s
		Audit.create({

						:record_id => params[:id],
						:audit_type => "RESOLVE DUPLICATE",
						:level => "Person",
						:reason => params[:comment],
						:change_log =>[{:audit_id => params[:audit_id]}]
		})



		redirect_to "#{params[:next_url].to_s}"
		
	end

	def confirm_duplicate_comment

		@section = "Confirm Duplicate"

		render :layout =>"plain_with_header"
		
	end

	def confirm_duplicate
		
		person = Person.find(params[:id])

		if ["DC ACTIVE", "DC COMPLETE", "DC POTENTIAL DUPLICATE","DC EXACT DUPLICATE"].include?(person.status)
			PersonRecordStatus.change_status(person, "MARKED APPROVAL",params[:comment])
			check_den_assignment
		end
		
		audit_record = Audit.find(params[:audit_id])
		if audit_record.record_id != params[:id]
			PersonRecordStatus.change_status(Person.find(audit_record.record_id), "DC DUPLICATE",params[:comment])
			Person.void_person(Person.find(audit_record.record_id),params[:user_id])
		end

		audit_log = audit_record.change_log rescue []

		audit_log.each do |d|
			ids = d["duplicates"].split("|")
			ids.each do |id|
				next if params[:id] == id
				PersonRecordStatus.change_status(Person.find(id), "DC DUPLICATE",params[:comment])
				Person.void_person(Person.find(id),params[:user_id])
			end
		end
		
		Audit.user = params[:user_id].to_s

		Audit.create({

						:record_id => params[:id],
						:audit_type => "RESOLVE DUPLICATE",
						:level => "Person",
						:reason => params[:comment],
						:change_log =>[{:audit_id => params[:audit_id]}]
		})
			
		unlock_users_record(person)
		redirect_to "#{params[:next_url].to_s}"

	end

	def manage_requests
		@section = "Manage Requests"
		@next_url = "/dc/manage_requests"
		render :layout => "landing"	
	end

	def reprint_requests
		@section ="Reprint Requests"

		@statuses = ["DC LOST","DC DAMAGED"]

		@next_url = "/dc/reprint_requests"

		@den = true

		render :template =>"/people/view"
	end

	def add_reprint_comment
		@action ="/mark_for_reprint"
		render :layout => "touch"
	end

	def approve_reprint
		person = Person.find(params[:id])
		PersonRecordStatus.change_status(person, "HQ REPRINT",params[:reason])
		Audit.create({
							:record_id => params[:id].to_s    , 
							:audit_type=>"DC APPROVE REPRINT",
							:level => "Person",
							:reason => params[:reason]})
		unlock_users_record(person)
		redirect_to "#{params[:next_url].to_s}"
	end

	def mark_for_reprint
		person = Person.find(params[:id])
		PersonRecordStatus.change_status(person, "DC #{params[:reason].upcase}".squish,params[:reason])
		PersonIdentifier.create({
                                      :person_record_id => person.id.to_s,
                                      :identifier_type => "Reprint Barcode", 
                                      :identifier => params[:barcode].to_s,
                                      :site_code => (person.site_code rescue (SETTINGS['site_code'] rescue nil)),
                                      :district_code => (person.district_code rescue SETTINGS['district_code']),
                                      :creator => params[:user_id]})

		Audit.create({
							:record_id => params[:id].to_s    , 
							:audit_type=>"DC REPRINT  #{params[:reason].upcase}",
							:level => "Person",
							:reason => params[:reason]})
		unlock_users_record(person)
		redirect_to "#{params[:next_url].to_s}"		
	end
	def sent_to_hq_for_reprint
		person = Person.find(params[:id])
		status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last
		PersonRecordStatus.change_status(person, status.status.gsub("DC","HQ"))
		unlock_users_record(person)
		redirect_to "/dc/reprint_requests?next_url=/dc/manage_requests?next_url=/"
	end
	def do_amend
		person = Person.find(params[:id])
		PersonRecordStatus.change_status(person, "DC AMEND")
		unlock_users_record(person)
		redirect_to "/dc/ammendment/#{params[:id]}?next_url=#{params[:next_url]}"
	end

	def amendment
		@person = Person.find(params[:id])
      	@status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last
      	@person_place_details = place_details(@person)
      	@burial_report = BurialReport.by_person_record_id.key(params[:id]).first
      	@comments = Audit.by_record_id_and_audit_type.keys([[params[:id],"DC INCOMPLETE"],
                                                          [params[:id],"DC REJECTED"],
                                                          [params[:id],"HQ REJECTED"],
                                                          [params[:id],"DC REAPPROVED"],
                                                          [params[:id],"DC DUPLICATE"],
                                                          [params[:id],"RESOLVE DUPLICATE"],
                                                          [params[:id],"DC REPRINT LOST"],
                                                          [params[:id],"DC REPRINT DAMAGED"],
                                                          [params[:id],"DC AMEND"]]).each
      	@amendment_audit = Audit.by_record_id_and_audit_type.key([params[:id],"DC AMEND"]).first
      	#@person.change_status("DC AMEND")
		@section ="Amendments"
		
	end

	def amendment_requests
		@section ="Amendments Requests"
		@statuses = ["DC AMEND"]
		@next_url = "/dc/amendment_requests"
		@den = true
		render :template =>"/dc/dc_view_cases"
	end

	def amendment_edit_field
		@person = Person.find(params[:id])
		@helpText = params[:field].humanize
      	@field = "person[#{params[:field]}]"
      	render :layout => "touch"
	end

	def amend_field
		
		person = Person.find(params[:id])
		amendment_audit = Audit.by_record_id_and_audit_type.key([params[:id],"DC AMEND"]).first
		if amendment_audit.present?
			param_keys = params[:person].keys
			hash = amendment_audit.change_log
			param_keys.each do |key|
				unless hash.present?
					hash = {}
				end
				hash.merge!(key => [params[:person][key],params[:prev][key]])
			end

			amendment_audit.change_log = nil
			amendment_audit.save
			amendment_audit.reload

			amendment_audit.change_log = hash
			amendment_audit.save
			amendment_audit.reload
		else
			amendment_audit = Audit.new
			amendment_audit.record_id = params[:id]
			amendment_audit.audit_type = "DC AMEND"
			amendment_audit.change_log = {}

			param_keys = params[:person].keys
			param_keys.each do |key|
				amendment_audit.change_log[key] = [params[:person][key],params[:prev][key]]
			end
			amendment_audit.save
		end
		redirect_to "/dc/ammendment/#{params[:id]}?next_url=#{params[:next_url]}"
	end

	def add_amendment_comment
		@action = '/proceed_amend'
		render :layout =>'touch'
	end

	def proceed_amend
		person = Person.find(params[:id])
		amendment_audit = Audit.by_record_id_and_audit_type.key([params[:id],"DC AMEND"]).first
		amend_keys = amendment_audit.change_log.keys
		amend_keys.each do |key|
			#person[key] = amendment_audit.change_log[key][0]
			person.update_attributes({key => amendment_audit.change_log[key][0]})
		end
		#person.save
 
		amendment_audit.reason = "DC Amendment : #{params[:reason]}"
		amendment_audit.level ="Person"
		amendment_audit.save

		PersonRecordStatus.change_status(person, "HQ AMEND")
		PersonIdentifier.create({
                                      :person_record_id => person.id.to_s,
                                      :identifier_type => "AMENDMENT Barcode", 
                                      :identifier => params[:barcode].to_s,
                                      :site_code => (person.site_code rescue (SETTINGS['site_code'] rescue nil)),
                                      :district_code => (person.district_code rescue SETTINGS['district_code']),
                                      :creator => params[:user_id]})
		unlock_users_record(person)
		redirect_to "#{params[:next_url].to_s}"
	end

	def printed_amendmets
		@prev_statuses = ["DC AMEND","DC LOST","DC DAMAGED"]
	    @statuses = ["HQ CAN PRINT"]
	    @section = "Printed Amended Certificates"
		@next_url = "/dc/confirmed_duplicated"
	    render :template =>"/people/view"
	end
	def counts_by_status
		status = params[:status]
		district_code = SETTINGS['district_code']
		if SETTINGS['site_type'] == "remote"
			district_code = User.current_user.district_code
		end
		key = [district_code,status]

		count = PersonRecordStatus.by_district_code_and_record_status.key(key).each.count

		render :text => {:count => count}.to_json	
	end

	def new_burial_report
		@burial_report = BurialReport.new
		@person = Person.find(params[:id])
		render :layout => "touch"
	end

	def create_burial_report
		BurialReport.create(params)
		redirect_to "/people/view/#{params[:person_record_id]}?next_url=#{params[:next_url]}"		
	end

	def sync
		if SETTINGS['site_type'] = "dc"
			@section ="Synced to HQ"
			@url = "/dc/query_hq_sync"
		else
			@section ="Synced to HQ"
			@url = "/people/query_hq_sync"
		end
		render :template =>"/people/view_sync"
	end

	def query_hq_sync
		page = params[:page] rescue 1
	    size = params[:size] rescue 7
	    people = []
	    if SETTINGS['site_type']=="dc"
	    	district_code = SETTINGS['district_code'].to_s
	    else
	    	district_code = User.current_user.district_code
	    end
		Sync.by_district_code.key(district_code).page(page).per(size).each do |sync|
			person = sync.person
			person_details = {
						id:          	person.id,
						first_name:  	person.first_name,
						last_name:   	person.last_name,
						middle_name: 	person.middle_name,
						gender:         person.gender,
						date_reported: 	person.created_at,
						record_status: 	sync.record_status,
						dc_sync_status: sync.dc_sync_status,
						hq_sync_status: sync.hq_sync_status
			}
			people << person_details
		end
		render :text => people.to_json
	end
	def check_den_assignment
		last_run_time = File.mtime("#{Rails.root}/public/sentinel").to_time
		job_interval = SETTINGS['ben_assignment_interval']
		job_interval = 1.5 if job_interval.blank?
		job_interval = job_interval.to_f
		now = Time.now

		if (now - last_run_time).to_f > job_interval
			if SETTINGS['site_type'].to_s != "facility"
				if (defined? PersonIdentifier.can_assign_den).nil?
					PersonIdentifier.can_assign_den = true
				end
				AssignDen.perform_in(job_interval)
			end
					        
		end
	end

	#Decentralize printing
	def print_certificates
		@section = "Print Certificates"
		@statuses = ["HQ CAN PRINT","HQ CAN PRINT AMENDED","HQ CAN PRINT LOST","HQ CAN PRINT DAMAGED"]
		@next_url = "/dc/print_certificates"
		@den = true 
		render :template =>"/people/view"		
	end

	protected
end
