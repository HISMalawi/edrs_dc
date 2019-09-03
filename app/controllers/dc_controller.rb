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
		begin
			unlock_users_record(person)
		rescue
		end

		redirect_to "#{params[:next_url].to_s}"
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


	def printed
		@section = "Printed Records"
		@next_url = params[:next_url]
		render :layout => "landing"
			
	end	

	def closed

		@section = "Printed Records"

		@statuses = ["HQ PRINTED","DC PRINTED"]

		@next_url = "/dc/closed"

		@den = true 

		render :template =>"/people/view"
		
	end

	def dc_printed

		@section = "Printed Records"

		@statuses = ["DC PRINTED"]

		@next_url = "/dc/dc_printed"

		@den = true 

		render :template =>"/people/view"
		
	end

	def hq_printed

		@section = "Printed Records"

		@statuses = ["HQ PRINTED"]

		@next_url = "/dc/dc_printed"

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


	    @existing_ids = []
	    @duplicates_audit = Audit.by_record_id_and_audit_type.key([@person.id.to_s, "POTENTIAL DUPLICATE"]).last
	    @statuses = []
	    @duplicates_audit.change_log.each do |log|
	    	unless  log['duplicates'].blank?
	    		ids = log['duplicates'].split("|")
	    		ids.each do |id|
	    			 @existing_ids << id
	    			 @statuses << PersonRecordStatus.by_person_recent_status.key(id).last.status
	    		end
	    	end
	    end

	    @existing_record  = Person.find(@existing_ids[params[:index].to_i])

	    @existing_place_details =  place_details(@existing_record)
	   
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
		if params[:barcode].present?
            Barcode.create({
                              :person_record_id => person.id.to_s,
                              :barcode => params[:barcode].to_s,
                              :district_code => (person.district_code  rescue SETTINGS['district_code']),
                              :creator => params[:user_id]
                              })			
			
		end

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

      	change_keys = @amendment_audit.change_log.keys rescue []
      	place0 = {}
      	place1 = {}
      	change_keys.each do |key|
      		place0[key] = (@amendment_audit.change_log[key][0] rescue "")
      		place1[key] = (@amendment_audit.change_log[key][1] rescue "")
      	end


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
			param_keys = params[:person].keys + (params[:prev].keys rescue [])
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

			param_keys = params[:person].keys + (params[:prev].keys rescue [])

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

		PersonRecordStatus.change_status(person, "HQ AMEND",params[:reason])
		if params[:barcode].present?
			PersonIdentifier.create({
                                      :person_record_id => person.id.to_s,
                                      :identifier_type => "AMENDMENT Barcode", 
                                      :identifier => params[:barcode].to_s,
                                      :site_code => (person.site_code rescue (SETTINGS['site_code'] rescue nil)),
                                      :district_code => (person.district_code rescue SETTINGS['district_code']),
                                      :creator => params[:user_id]})			
		end

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
			district_code = session[:district_code]
		end
		key = [district_code,status]

		#count = PersonRecordStatus.by_district_code_and_record_status.key(key).each.count

		connection = ActiveRecord::Base.connection
		count =  connection.select_all("SELECT count(a.person_record_id) as total FROM  (SELECT DISTINCT person_record_id FROM person_record_status 
                                                        WHERE status ='#{status}' AND district_code='#{district_code}' AND voided=0 ) a").as_json.last['total'] rescue 0

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
		@statuses = ["HQ CAN PRINT","HQ CAN PRINT AMENDED","HQ CAN PRINT LOST","HQ CAN PRINT DAMAGED", "HQ CAN RE PRINT"]
		@available_printers = SETTINGS["printer_name"].split(',')
		@next_url = "/dc/print_certificates"
		@den = true 
		render :template =>"/dc/default_batch"		
	end

	def search_records_to_print
		status = params[:statuses]
	    page = params[:page] rescue 0
	    size = params[:size] rescue 40
	    people = []
	    record_status = []

	    
	    RecordStatus.where("status IN('#{params[:statuses].join("','")}') AND voided = 0 AND district_code = '#{User.current_user.district_code}'").limit(size.to_i).offset(page.to_i  * size.to_i).each do |status|
	      
	      person = Record.find(status.person_record_id) rescue nil
 		  people << fields_for_data_table(person)
	    end
	    render :text => people.to_json
	end

	def do_print_these
    	selected = params[:selected].split("|")

    	paper_size = "A5" #GlobalProperty.find("paper_size").value rescue "A4"
    
	    if paper_size == "A4"
	       zoom = 0.83
	    elsif paper_size == "A5"
	       zoom = 0.6
	    end
     
	    selected.each do |key|

	      person = Person.find(key.strip)

	      if SETTINGS['print_qrcode']
	      	  if !File.exist?("#{SETTINGS['qrcodes_path']}QR#{person.id}.png")
	      		create_qr_barcode(person)
	      		sleep(1)
	      	  end
	      else
		      if !File.exist?("#{SETTINGS['barcodes_path']}#{person.id}.png")
		        create_barcode(person)
		        sleep(1)
		      end	      	
	      end


	      next if person.blank?
	      
	      id = person.id
	      
	      output_file = "#{SETTINGS['certificates_path']}#{id}.pdf"

	      input_url = "#{CONFIG["protocol"]}://#{request.env["SERVER_NAME"]}:#{request.env["SERVER_PORT"]}/death_certificate/#{id}"

	      Kernel.system "#{SETTINGS['wkhtmltopdf']} --zoom #{zoom} --page-size #{paper_size} #{input_url} #{output_file}"
	        #PDFKit.new(input_url, :page_size => paper_size, :zoom => zoom).to_file(output_file)

	      Kernel.system "lp -d #{params[:printer_name]} #{SETTINGS['certificates_path']}#{id}.pdf\n"

	      PersonRecordStatus.change_status(person,"DC PRINTED")
	  
	   end
	    
	   redirect_to "/dc/print_certificates?next_url=/dc/manage_cases?next_url=/" and return
	end

	def death_certificate
		@person = Person.find(params[:id])
	    @place_of_death = place_of_death(@person)
	    @drn = @person.drn
	    @den = @person.den

	    if SETTINGS['print_qrcode']
	      	  if !File.exist?("#{SETTINGS['qrcodes_path']}QR#{@person.id}.png")
	      		create_qr_barcode(@person)
	      		sleep(5)
	      		redirect_to request.fullpath and return
	      	  end
	     else
		      if !File.exist?("#{SETTINGS['barcodes_path']}#{@person.id}.png")
		        create_barcode(@person)
		        sleep(5)
		        redirect_to request.fullpath and return
		      end	      	
	    end
	    @barcode = File.read("#{CONFIG['barcodes_path']}#{@person.id}.png") rescue nil

	    @date_registered = @person.created_at
	    PersonRecordStatus.by_person_record_id.key(@person.id).each.sort_by{|s| s.created_at}.each do |state|
	      if state.status == "HQ ACTIVE"
	          @date_registered = state.created_at
	          break;
	      end
	    end
	    
	  
	    render :layout => false, :template => 'dc/death_certificate_print_a5'
	end

	def print_preview
	    @section = "Print Preview"
	    @targeturl = "/print" 
	    @person = Person.find(params[:id])
	    @available_printers = SETTINGS["printer_name"].split(',')
  	end

	protected
end
