class DcController < ApplicationController

	before_filter :facility_info

	before_filter :check_user_level_and_site

	def index

	  @facility = facility

      @district = district

      @section = "Home"

      render :layout => "landing"
		
	end

	def check_completeness

		person = Person.find(params[:id])

		if record_complete?(person)
				PersonRecordStatus.change_status(person, "DC COMPLETE","Marked as complete")
				redirect_to "#{params[:next_url].to_s}"
		else
				PersonRecordStatus.change_status(person, "DC INCOMPLETE", "System marked as incomplete")
				redirect_to "/people/view/#{params[:id]}?next_url=#{params[:next_url]}&topic=Completeness Check&error=Record not complete"
		end
		
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


		if record_complete?(person)
			   duplicate = nil
			   record = {}
	           record["first_name"] = person.first_name
	           record["last_name"] = person.last_name
	           record["middle_name"] = (person.middle_name rescue nil)
	           record["gender"] = person.gender
	           record["place_of_death_district"] = person.place_of_death_district
	           record["birthdate"] = person.birthdate
	           record["date_of_death"] = person.date_of_death
	           record["mother_last_name"] = (person.mother_last_name rescue nil)
	           record["mother_middle_name"] = (person.mother_middle_name rescue nil)
	           record["mother_first_name"] = (person.mother_first_name rescue nil)
	           record["father_last_name"] = (person.father_last_name rescue nil)
	           record["father_middle_name"] = (person.father_middle_name rescue nil)
	           record["father_first_name"] = (person.father_first_name rescue nil)
	           record["id"] = person.id
	           record["district_code"] = SETTINGS["district_code"]

	           if SETTINGS["potential_duplicate"]
	           		duplicate =   SimpleElasticSearch.query_duplicate_coded(record,SETTINGS['duplicate_precision'])
	           end
				
			   if duplicate.blank?  ||  true
					status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last

					if status.status =="HQ REJECTED"
						PersonRecordStatus.change_status(person, "DC REAPPROVED")
					else
						PersonRecordStatus.change_status(person, "MARKED APPROVAL")
					end
					
					last_run_time = File.mtime("#{Rails.root}/public/sentinel").to_time
			        job_interval = SETTINGS['ben_assignment_interval']
			        job_interval = 1.5 if job_interval.blank?
			        job_interval = job_interval.to_f
			        now = Time.now
			        if (now - last_run_time).to_f > job_interval
			          AssignDen.perform_in(1)
			        end
					#Audit.create({:record_id => params[:id].to_s,:audit_type=>"DC APPROVED",:level => "Person",:reason => "Approve record"})
					render :text => {marked: true}.to_json
				else
					can_mark_as_potential_duplicate = false

					existing = []
					ids = []
					duplicate.each do |dup| 
					 	if dup[0] != params[:id]
					 		existing << dup
					 		ids << dup[0]
					 		dup_status = Person.find(dup[0]).status rescue ""
					 		can_mark_as_potential_duplicate = true if dup_status !="DC POTENTIAL DUPLICATE"
					 	end
					end
					if can_mark_as_potential_duplicate 
						change_log = [{:duplicates => ids.to_s}]
						Audit.create({
	                      :record_id  => person.id.to_s,
	                      :audit_type => "POTENTIAL DUPLICATE",
	                      :reason     => "Record is a potential",
	                      :change_log => change_log
					     })
					     PersonRecordStatus.change_status(person, "DC POTENTIAL DUPLICATE","Record is a potential")

					     render :text => {:duplicates=> true, :people => existing}.to_json
					else
						PersonRecordStatus.change_status(person, "MARKED APPROVAL")
						render :text => {marked: true}.to_json
					end
				end
			    #redirect_to "#{params[:next_url].to_s}"

		else
			PersonRecordStatus.change_status(person, "DC INCOMPLETE","Approve record not successful")
			Audit.create({
				:record_id => params[:id].to_s    , 
				:audit_type=>"DC INCOMPLETE",
				:level => "Person",
				:reason => "Approve record not successful"})
			render :text => {incomplete: true}.to_json
				#redirect_to "/people/view/#{params[:id]}?next_url=#{params[:next_url]}&topic=Can not approve Record&error=Record not complete"
		end
		
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
		redirect_to params[:next_url]
	end

	def reject_record
			person = Person.find(params[:id])
			PersonRecordStatus.change_status(person, "DC REJECTED",params[:reason])			
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

		@statuses = ["HQ CLOSED"]

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

		@statuses = ["DC INCOMPLETE"]

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
		PersonRecordStatus.change_status(person, "DC DUPLICATE",params[:comment])
		Person.void_person(person,params[:user_id])
		Audit.user = params[:user_id].to_s

		Audit.create({

						:record_id => params[:id],
						:audit_type => "RESOLVE DUPLICATE",
						:level => "Person",
						:reason => params[:comment],
						:change_log =>[{:audit_id => params[:audit_id]}]
		})

		if eval(params[:select].to_s)
			PersonRecordStatus.change_status(Person.find(params[:audit_id]), "MARKED APPROVAL",params[:comment])
		end
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

		redirect_to "#{params[:next_url].to_s}"		
	end
	def sent_to_hq_for_reprint
		person = Person.find(params[:id])
		status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last
		PersonRecordStatus.change_status(person, status.status.gsub("DC","HQ"))
		redirect_to "/dc/reprint_requests?next_url=/dc/manage_requests?next_url=/"
	end
	def do_amend
		person = Person.find(params[:id])
		PersonRecordStatus.change_status(person, "DC AMEND")
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

	protected
end
